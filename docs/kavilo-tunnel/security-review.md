# Security & performance review — v0.1.1

A focused review of kavilo-tunnel's client + server surface for performance
and security issues, with applied fixes and notes on deferred items.

## Threat model

**Trust boundary:** the public internet → edge proxy → tunnel client → local
origin. The edge proxy is the only piece exposed to untrusted public traffic.
The control plane (gRPC) is exposed publicly but requires a valid bearer
token issued out-of-band.

**Not in scope:** physical/OS-level attacks on either the VPS or the user's
laptop; supply-chain attacks on Rust crates; users with valid tokens are
trusted not to abuse them (per-user rate limiting is future work).

## Findings & fixes

### Fixed in this review

| # | Severity | Issue | Fix |
|---|---|---|---|
| 1 | High | No request body size limit on edge — public client could stream unlimited bytes through a tunnel (DoS) | Added `--max-request-body-bytes` (default 100 MiB). Per-request body pump tracks cumulative bytes; exceeds → send `Cancel` upstream and stop pumping. Metric `kavilo_edge_body_limit_exceeded_total` counts events |
| 2 | High | Server has no timeout on the initial `Hello` frame — a stalled client leaks a server-side gRPC stream + task | Wrapped `inbound.next()` in `tokio::time::timeout(10s, …)`. Returns `DEADLINE_EXCEEDED` if no Hello in 10s |
| 3 | High | Client has no `connect_timeout` on the origin reqwest call — dead origin hangs per-request task | `reqwest::Client::builder().connect_timeout(Duration::from_secs(5))` |

### Confirmed not issues (verified during review)

- **Token strength**: 32 bytes from `OsRng`, base32-encoded, blake3-hashed
  in DB. Brute-force infeasible. Timing attacks against the DB byte-compare
  are theoretical but exploitable only against tokens with low entropy
  — ours are 256 bits.
- **TLS configuration**: tonic 0.12 + rustls 0.23 default to TLS 1.2+
  minimum, modern ciphers, no SSL renegotiation. Server `Identity::from_pem`
  is fed an LE-issued cert.
- **Upgrade flow ordering**: `hyper::upgrade::on(&mut req)` is called *before*
  `req.into_body()` is consumed for non-upgrade requests — correct.
- **Race-safe takeover**: `session_id` per `TunnelHandle` + `remove_if_session`
  prevents the evicted tunnel's cleanup from clobbering the successor's
  registry entry.
- **ACME**: bounded polling on order status + best-effort cleanup of TXT
  records on `Invalid` order. Account credentials persisted at mode 0600.
- **Header forwarding**: `X-Forwarded-For` chain is appended-to (trust the
  chain). `X-Real-IP` is overwritten with the actual peer IP. Hop-by-hop
  response headers (`Transfer-Encoding`, `Connection`, `Keep-Alive`,
  `Proxy-Connection`) are stripped on the way out (except for 101 upgrades).
- **Slug derivation collisions**: `create_user` retries up to 8 times on
  `users_slug_key` unique violation.

### Noted, deferred (not fixing in this review)

| Item | Why deferred |
|---|---|
| No per-IP rate limit at the edge | Adds `governor` dep; not justified at current scale. Defense-in-depth would be helpful eventually |
| `last_used_at` DB write on every auth | Cheap (indexed UPDATE); could batch to once-per-tunnel-session if/when it shows up in DB profiling |
| `std::sync::Mutex<HashMap>` on dispatcher inflight map | Correct for short critical sections (lock held for HashMap insert/get only, no await). Would migrate to `DashMap` only if QPS demanded it |
| Per-request `Vec<u8>` ↔ `Bytes` conversions | `Bytes::from(Vec)` is zero-copy; the only real allocation is the proto-defined `Vec<u8> data` field, which is mandatory for prost encoding |
| Email logged in tunnel-connect tracing line | Useful for operator visibility; acceptable for an internal-use tool. Would scrub for multi-tenant SaaS |
| Connection accept loop has no flood protection | tokio tasks are cheap (~1 KiB each); kernel-level limits (file descriptors, ephemeral ports) bound concurrent connections. Adding semaphore + SYN backoff would be defense-in-depth |
| WebSocket subprotocol validation | Not the proxy's concern — origin handles it |
| `serve_connection_with_upgrades` has no overall connection age limit | hyper 1.x does honor `keepalive_timeout` defaults; for explicit max-age you'd wrap in a `tokio::time::timeout(MAX_AGE, conn)` |

## Settings & their security implications

| Setting | Default | Adjust when |
|---|---|---|
| `--max-request-body-bytes` | 100 MiB | Raise for known large-upload workflows; lower for stricter DoS guard |
| `Dispatcher` per-request channel | 32 frames | Lower if you suspect HOL blocking; raise if many small chunks per request stall |
| `Dispatcher` max-concurrent per tunnel | 256 | Lower for stricter quota per tunnel; raise if your origins handle high concurrency well |
| HTTP/2 stream window | 4 MiB | Tonic default of 64 KiB throttles streaming proxies. Raise further if testing reveals bottlenecks |
| HTTP/2 keepalive | 30s / 20s timeout | Detects dead peers cleanly. Most networks are fine with this |
| Hello timeout | 10s | Lower if you only allow well-connected clients; raise for laggy networks |
| Origin connect timeout | 5s | Raise for slow-to-start local services |

## Operational recommendations

1. **Set `Actions` minute budget** — at the GitHub level, raise the Actions
   spending limit to $5 so the source-repo dispatcher workflows can run
   even between calendar-month resets. The release build itself is on the
   public tap and free.
2. **Monitor `kavilo_edge_body_limit_exceeded_total`** — non-zero means
   something is hitting the body cap; investigate the source IP and the
   destination tunnel.
3. **Rotate the bearer token periodically** by issuing a new one via
   `admin issue-token` and revoking the old via `DELETE FROM api_tokens
   WHERE id = …` once the new one is in use.
4. **Backup the Postgres `kavilo` database** — `pg_dump` on a cron, store
   somewhere off-box. The schema is small (~3 tables, 1 row each at low
   scale).
5. **Keep the lego-kavilo IAM user scoped tightly** — already done; it
   only has `route53:ChangeResourceRecordSets` on
   `Z0630689ACVSKG4NXWCI`. Don't broaden.

# kavilo-tunnel — user guide

This is the client guide. If you're operating the server side, see
[`docs/naming-and-routing.md`](naming-and-routing.md) for the schema and
multi-client behaviour.

## What it does

You run a local service (`http://127.0.0.1:3000` or whatever). `kavilo-tunnel`
opens a persistent connection to the operator's server and gets you a public
HTTPS URL that forwards traffic to your local service. Useful for sharing
work-in-progress with someone, exposing a local webhook receiver to the
internet, etc.

## Install

### macOS

```sh
brew install kavilo-bot/tap/kavilo-tunnel
```

That gives you the `kavilo-tunnel` command.

### Debian / Ubuntu (amd64) — apt repo

Add the kavilo apt repo once, then install / upgrade with normal `apt`:

```sh
# add the keyring
sudo install -d /etc/apt/keyrings
curl -fsSL https://kavilo-bot.github.io/homebrew-tap/apt/keyring.asc \
  | sudo gpg --dearmor -o /etc/apt/keyrings/kavilo.gpg

# add the source
echo "deb [signed-by=/etc/apt/keyrings/kavilo.gpg] https://kavilo-bot.github.io/homebrew-tap/apt stable main" \
  | sudo tee /etc/apt/sources.list.d/kavilo.list

sudo apt update
sudo apt install kavilo-tunnel
```

Upgrades are picked up by `sudo apt update && sudo apt upgrade` from then on.

### Debian / Ubuntu (amd64) — direct .deb (no apt repo)

```sh
KAVILO_VER=0.1.0
curl -fsSL -o /tmp/kavilo-tunnel.deb \
  https://kavilo-bot.github.io/homebrew-tap/apt/pool/main/k/kavilo-tunnel/kavilo-tunnel_${KAVILO_VER}_amd64.deb
sudo dpkg -i /tmp/kavilo-tunnel.deb
```

### Other Linux / from source

```sh
git clone https://github.com/kavilo-bot/kavilo-tunnel.git
cd kavilo-tunnel
cargo build --release --bin kavilo-tunnel
# binary is at target/release/kavilo-tunnel
```

Requires Rust 1.80+ and `protoc` (`apt install protobuf-compiler` on Debian).

## First-time setup

You need a **token** issued by the server operator. They'll give you one
out-of-band — it looks like:

```
h4ynciplc6gpjjr6422vytufs6bc3onjmkbqkckrzm4whfslrb5q
```

Save it and the server endpoint with `login`:

```sh
kavilo-tunnel login \
  --token h4ynciplc6gpjjr6422vytufs6bc3onjmkbqkckrzm4whfslrb5q \
  --endpoint https://tnl.example.com:443
```

This writes `~/.kavilo-tunnel/config.yml` (mode 0600). You only do this once
per machine. From now on `kavilo-tunnel tunnel ...` picks up the endpoint
and token automatically.

> **Picking a port.** The server serves the control plane on **both** the
> dedicated `:7777` port and the public HTTPS edge port (`:443`). Use `:443`
> if your network blocks non-standard ports (corporate firewalls, cafes,
> hotels) — most public networks only allow outbound `:443` and `:80`. Use
> `:7777` if you want the control plane and edge traffic on separate ports
> for observability or rate-limiting reasons. Both work identically.

## Open a tunnel

### Quick tunnel (random, throwaway URL)

```sh
kavilo-tunnel tunnel --url http://127.0.0.1:3000
```

Prints something like:

```
  kavilo-tunnel ready
  public URL: https://quick-fox-3947.tnl.example.com/
  forwarding to: http://127.0.0.1:3000
```

The URL changes every time you reconnect. Good for one-off demos.

### Named tunnel (stable URL)

```sh
kavilo-tunnel tunnel --url http://127.0.0.1:3000 --name myapp
```

URL becomes `https://myapp-<your-slug>.tnl.example.com/` and stays
the same across reconnects, forever. Good for webhooks, repeated demos, dev
preview links shared with teammates.

You can have several named tunnels open at once with distinct `--name`s — one
per local service.

### Take over a name you already hold

If you're connected from another machine with the same `--name`, a fresh
attempt will sit in the reconnect loop waiting. To forcibly claim the slot:

```sh
kavilo-tunnel tunnel --url ... --name myapp --takeover
```

The old client gets disconnected and starts retrying; the new one wins. This
only works between sessions of the **same user** — names are per-user, so two
people both running `--name dev` get separate URLs without conflict.

## How URLs work

Stable subdomain format: `{name}-{your-slug}.<base-host>`.

- `{name}` is whatever you pass to `--name`.
- `{your-slug}` is set when your account was created (something like
  `alice-7f0c`). It's permanent and shared across all your tunnels.
- `<base-host>` is operator-configured (e.g. `tnl.example.com`).

So `--name laptop` for user `alice-7f0c` always resolves to
`https://laptop-alice-7f0c.tnl.example.com/`.

Anonymous (no `--name`) URLs use a random `adjective-animal-NNNN` pattern and
die when you disconnect.

## Running in the background

`kavilo-tunnel tunnel` is foreground — it blocks until you Ctrl-C it. To
run it as a background daemon on macOS or Linux, the simplest options:

**Linux (systemd, per-user):**

```ini
# ~/.config/systemd/user/kavilo-tunnel.service
[Unit]
Description=kavilo-tunnel persistent tunnel for myapp

[Service]
ExecStart=/usr/bin/kavilo-tunnel tunnel --url http://127.0.0.1:3000 --name myapp
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
```

```sh
systemctl --user daemon-reload
systemctl --user enable --now kavilo-tunnel
journalctl --user -u kavilo-tunnel -f   # live logs
```

**macOS (launchd):** see `man launchd.plist` — drop a `LaunchAgent` plist at
`~/Library/LaunchAgents/com.kavilo.tunnel.plist` with `ProgramArguments` set
to the command line.

**Or quick-and-dirty:** `nohup kavilo-tunnel tunnel ... &` (logs go to
`nohup.out`).

The client has built-in **exponential backoff reconnect**, so once it's
running it'll survive network drops, your laptop sleeping, the server
restarting, etc. without intervention.

## Troubleshooting

### `Error: call Tunnel.Open … AlreadyExists: tunnel '<name>' is already connected from another client`

Another machine of yours is holding that name. Either disconnect it, or use
`--takeover`.

### `Error: call Tunnel.Open … PermissionDenied: invalid token`

Token is wrong or has been revoked. Get a fresh one from the operator and
re-run `kavilo-tunnel login --token …`.

### `Error: connect to https://… (Connection refused / timed out)`

Network can't reach the control endpoint. Check:

```sh
curl -sv https://tnl.example.com:443 2>&1 | head -5
```

If TLS handshakes on `:443`, the server's up — re-run `kavilo-tunnel login
--endpoint https://tnl.example.com:443` to switch to the firewall-friendly
port. If `:443` itself is blocked, your network is filtering outbound HTTPS
(rare). If only `:7777` is blocked, `:443` will work as a drop-in.

### Public URL returns `502 no active tunnel for this hostname`

You hit a URL that has no tunnel claiming that subdomain. Common causes:

- Typo in the subdomain.
- You're using an **anonymous** tunnel URL from a prior session (those die on
  disconnect).
- Your client is in reconnect backoff (look at its logs).

### Public URL returns `503 tunnel is at its concurrent-request capacity`

Your local service is generating too many concurrent in-flight requests
through one tunnel (>256 by default). Either reduce concurrency or ask the
operator to bump `--max-concurrent`.

### Logs

The client logs to stdout. Increase verbosity with:

```sh
RUST_LOG=debug kavilo-tunnel tunnel --url …
```

## Web UI

A web dashboard is mounted at the base host:

```
https://kavilo-tunnel.weganar.com/
```

It's **invite-only** and uses **GitHub OAuth** for login (no passwords).

### As a user

Once an admin has sent you an invite URL (looks like
`https://kavilo-tunnel.weganar.com/invite/abc123...`):

1. Open the invite URL in a browser
2. Click **Accept & sign in with GitHub**
3. Authorize the GitHub OAuth app
4. You land on the dashboard — your account is created automatically

From the dashboard you can:

- See your currently-connected tunnels (live)
- Mint new API tokens (plaintext shown once — copy it immediately)
- Revoke tokens
- Copy the `kavilo-tunnel login` command with your token pre-filled

### As an admin

Log in via `https://kavilo-tunnel.weganar.com/login`, then visit `/admin`
for:

- Server-wide active tunnel list (`/admin/tunnels`)
- User list (`/admin/users`)
- Invite creation + history (`/admin/invites`)

To invite someone:

1. Go to `/admin/invites`
2. Optionally bind the invite to an email or GitHub username (recommended —
   prevents the link from being used by someone else)
3. Optionally check **Grant admin privileges** if they should be an admin
4. Click **Create invite**
5. Copy the URL and send it to them out-of-band (Slack, email, etc.)

Invites expire after 7 days and can be used once.

### Server-side setup (operator)

The web UI requires:

- `DATABASE_URL` — Postgres connection (already needed for named tunnels)
- `KAVILO_GITHUB_CLIENT_ID` + `KAVILO_GITHUB_CLIENT_SECRET` — from a GitHub
  OAuth App registered at https://github.com/settings/applications/new with
  the callback URL `https://YOUR-BASE-HOST/auth/github/callback`
- `KAVILO_SESSION_SECRET` (recommended) — 64 hex chars (32 bytes). If
  unset, a fresh random one is generated at boot, so sessions don't
  survive restart. Generate one with `openssl rand -hex 32`.

All three go in `/etc/kavilo-tunneld/env`.

The first user to log in via OAuth using an email that already exists in
the `users` table will have their existing record linked to GitHub
automatically (no invite required for pre-existing accounts). New users
require an invite.

## Operator: server-side admin

These commands are for whoever runs `kavilo-tunneld` on the VPS. End users
don't need them.

### See currently-active tunnels

The server exposes a JSON endpoint on its loopback metrics port (default
`127.0.0.1:9090`, no auth — only reachable from the host):

```sh
ssh <server> 'curl -sS http://127.0.0.1:9090/admin/tunnels | jq .'
```

Each entry includes the subdomain, public URL, owning user's email, client
version, peer IP, session UUID, ISO-8601 connect time, and age in seconds.

Handy variants:

```sh
# Just one line per tunnel
ssh <server> 'curl -sS http://127.0.0.1:9090/admin/tunnels | \
  jq -r ".[] | \"\(.subdomain)  \(.user_email)  v\(.client_version)  \(.peer_addr)  age=\(.age_seconds)s\""'

# How many tunnels are connected right now
ssh <server> 'curl -sS http://127.0.0.1:9090/admin/tunnels | jq length'

# Old clients that haven't upgraded
ssh <server> 'curl -sS http://127.0.0.1:9090/admin/tunnels | \
  jq ".[] | select(.client_version != \"0.1.4\")"'
```

### Prometheus metrics

Same port, different path:

```sh
ssh <server> 'curl -sS http://127.0.0.1:9090/metrics'
```

Notable series:

| Metric | Type | What it means |
|---|---|---|
| `kavilo_tunnels_active` | gauge | Currently-connected tunnels |
| `kavilo_tunnels_connected_total` | counter | Lifetime connects (since process start) |
| `kavilo_edge_requests_total` | counter | Public requests received by the edge |
| `kavilo_edge_responses_total{code="…"}` | counter | Edge responses by status code |
| `kavilo_edge_body_limit_exceeded_total` | counter | Requests cancelled for exceeding `--max-request-body-bytes` |

### Issue / revoke tokens

```sh
# Add a user
sudo /usr/local/bin/kavilo-tunneld admin create-user --email someone@example.com

# Issue a token (prints plaintext ONCE — save it, paste to the user)
sudo /usr/local/bin/kavilo-tunneld admin issue-token \
  --email someone@example.com --name "their-laptop"

# Revoke (delete in DB)
sudo -u postgres psql -d kavilo -c \
  "DELETE FROM api_tokens WHERE id = '<token-uuid>';"
```

### Restart / drain

`SIGTERM` triggers graceful shutdown — the edge stops accepting new
requests, in-flight ones get a `Cancel`, then gRPC streams close. Connected
clients reconnect within seconds via their backoff loop, so a restart is
near-invisible to end users.

```sh
ssh <server> 'sudo systemctl restart kavilo-tunneld'
```

## Command reference

```text
kavilo-tunnel login --token <TOKEN> [--endpoint URL]
    Save the endpoint + token to ~/.kavilo-tunnel/config.yml.

kavilo-tunnel tunnel --url URL [OPTIONS]
    Open a tunnel.

      --url URL              Local URL to forward to. Required.
      --name NAME            Use a named persistent tunnel. Subdomain
                             becomes "<name>-<your-slug>".
      --endpoint URL         Override the saved control endpoint.
      --token TOKEN          Override the saved token (env: KAVILO_TOKEN).
      --ca-cert PATH         Trust a self-signed CA at PATH for the control
                             endpoint (dev only; production uses public LE).
      --takeover             Forcibly evict another client of yours holding
                             the same --name.

kavilo-tunnel --version
kavilo-tunnel --help
```

Anything else, check `kavilo-tunnel tunnel --help`.

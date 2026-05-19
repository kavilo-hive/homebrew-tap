# Naming and routing

How public URLs are built, what's persistent, and what happens when two
clients fight over the same name.

## Subdomain format

Every tunnel gets a public hostname of the form:

```
<subdomain>.<base_host>
```

`<base_host>` is the operator-configured value of `--base-host` (e.g.
`tnl.example.com`). The interesting part is `<subdomain>`,
which is chosen at connect time depending on whether the client passed
`--name`:

| Client invocation | Subdomain pattern | Persistent? |
|---|---|---|
| `kavilo-tunnel tunnel --url http://127.0.0.1:N` | `<adjective>-<animal>-<NNNN>` (e.g. `quick-fox-3947`) | Random each connect |
| `kavilo-tunnel tunnel --url ... --name laptop` | `laptop-<userslug>` (e.g. `laptop-alice-7f0c`) | Stable forever |

Authentication is required either way — the only difference is whether
the URL is disposable or sticky.

## What `userslug` is

When `kavilo-tunneld admin create-user --email <addr>` runs, the server
generates a `slug` and stores it in the `users` row. The rule is:

```
email "alice@example.com"
  ↓ take local part:             "alice"
  ↓ keep only [a-z0-9-], lower:   "alice"
  ↓ append "-" + 2 random bytes:  "alice-7f0c"
```

The 4 hex characters are 2 bytes from `OsRng`. They exist purely to
disambiguate users whose email local-parts collide (e.g. two
`alice@`-something users). The slug is generated once, stored, and
reused for every connection that user makes. It is not derived from any
machine-specific value.

If the slug is ugly, you can rewrite it after the fact:

```sh
docker exec kavilo-postgres psql -U kavilo -c \
  "UPDATE users SET slug = 'alice' WHERE email = 'alice@example.com';"

# Then also update any existing named tunnels you want to keep
docker exec kavilo-postgres psql -U kavilo -c \
  "UPDATE tunnels SET subdomain = REPLACE(subdomain, '-alice-7f0c', '-alice')
   WHERE subdomain LIKE '%-alice-7f0c';"
```

Take down any live tunnels first; they'll come back on the new subdomain
on the next reconnect.

## Uniqueness — what's enforced where

The `tunnels` table has two uniqueness constraints (`migrations/0001_init.sql`):

```sql
UNIQUE (user_id, name)   -- within your account, names can't repeat
UNIQUE (subdomain)       -- globally, subdomains can't collide
```

Together with the per-user slug, this means:

| Scenario | Subdomain A | Subdomain B | Coexist? |
|---|---|---|---|
| You: `--name laptop` twice from the same machine, sequentially | `laptop-alice-7f0c` | (same row) | yes — DB row reused |
| You: `--name laptop` from laptop + desktop simultaneously | `laptop-alice-7f0c` | `laptop-alice-7f0c` | **no** — first wins |
| You: `--name laptop` and `--name desktop` simultaneously | `laptop-alice-7f0c` | `desktop-alice-7f0c` | yes |
| You vs. another user, both `--name laptop` | `laptop-alice-7f0c` | `laptop-bob-3b9e` | yes — different slugs |

So the only practical responsibility is: **pick distinct names for the
distinct roles your machines play.** You can't accidentally clobber a
prior tunnel of your own — the DB row gets reused, not duplicated.

## Two clients, same `(user, name)`

When client B tries to register a subdomain that's already live in the
in-memory registry (because client A holds it), the server returns gRPC
`AlreadyExists`:

```
status: AlreadyExists, message: "tunnel 'laptop' is already connected
from another client"
```

Client A keeps serving traffic, unaffected. Client B's main loop logs
the error and enters its reconnect-backoff loop (1s, 2s, 4s, … capped at
60s, with jitter). As soon as A disconnects — kill, network drop,
laptop sleep — the registry frees the subdomain, and B's next retry
succeeds. **Failover is automatic.**

If you want B to forcibly take over from A instead of waiting, that
requires a `--takeover` flag that sends `Cancel` to the existing tunnel
on conflict. Not yet implemented.

## Anonymous tunnels and persistence

Anonymous tunnels still require a valid bearer token — "anonymous" only
refers to the subdomain being throwaway, not to the user being
unauthenticated. The connection is fully authenticated; only the URL is
disposable.

Random subdomains use the format `<adjective>-<animal>-<NNNN>` from a
small built-in word list (~24 adjectives × ~24 animals × 9000 numbers,
collision-checked against the live registry). The server's word list
lives in `crates/kavilo-tunneld/src/subdomain.rs`.

Random subdomains are NOT persisted to the `tunnels` table — they live
only in the in-memory registry and die when the client disconnects.

## DB schema, condensed

```
users      (id, email UNIQUE, slug UNIQUE, created_at)
api_tokens (id, user_id → users, token_hash UNIQUE, name, created_at, last_used_at)
tunnels    (id, user_id → users, name, subdomain UNIQUE, created_at,
            UNIQUE (user_id, name))
```

Plaintext tokens are never stored — only `blake3(token)` as `BYTEA`.
Token plaintext is shown once by `admin issue-token` and never again.

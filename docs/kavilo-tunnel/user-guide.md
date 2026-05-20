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

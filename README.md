# kavilo

> A lightweight personal AI assistant — single binary, zero dependencies.

This is the **public Homebrew tap** and binary mirror for
[`kavilo`](https://github.com/kavilo-bot/kavilo). Use it to install
`kavilo` on macOS / Linux, run it as a background service, and connect it
to chat platforms.

The `kavilo-bot/kavilo` source repository is currently private. All
public release artifacts live here under
[Releases](https://github.com/kavilo-bot/homebrew-tap/releases).

## Contents

- [Install](#install)
- [Quick start](#quick-start)
- [Run as a background service](#run-as-a-background-service)
- [Configuration](#configuration)
- [Chat channels](#chat-channels)
- [MCP (Model Context Protocol)](#mcp-model-context-protocol)
- [Profiles](#profiles)
- [Command reference](#command-reference)
- [Upgrading](#upgrading)
- [Uninstalling](#uninstalling)
- [Troubleshooting](#troubleshooting)
- [Security & sandbox notes](#security--sandbox-notes)
- [License](#license)

## Install

### macOS / Linux (Homebrew)

```bash
brew install kavilo-bot/tap/kavilo
```

That single command:

1. taps `kavilo-bot/homebrew-tap`
2. downloads the platform-matching binary (`darwin_arm64`, `darwin_amd64`,
   `linux_arm64`, or `linux_amd64`) from this repo's latest release
3. installs `kavilo` to `$(brew --prefix)/bin/kavilo`
4. registers a `brew services` definition you can use to keep it running
   in the background

### Direct binary download

Each release ships unversioned aliases so the URLs are stable across
versions:

```bash
# macOS (Apple Silicon)
curl -LO https://github.com/kavilo-bot/homebrew-tap/releases/latest/download/kavilo_darwin_arm64.zip
unzip kavilo_darwin_arm64.zip && sudo mv kavilo /usr/local/bin/

# macOS (Intel)
curl -LO https://github.com/kavilo-bot/homebrew-tap/releases/latest/download/kavilo_darwin_amd64.zip
unzip kavilo_darwin_amd64.zip && sudo mv kavilo /usr/local/bin/

# Linux (x86_64)
curl -LO https://github.com/kavilo-bot/homebrew-tap/releases/latest/download/kavilo_linux_amd64.tar.gz
tar xzf kavilo_linux_amd64.tar.gz && sudo mv kavilo /usr/local/bin/

# Linux (arm64)
curl -LO https://github.com/kavilo-bot/homebrew-tap/releases/latest/download/kavilo_linux_arm64.tar.gz
tar xzf kavilo_linux_arm64.tar.gz && sudo mv kavilo /usr/local/bin/

# Windows
curl -LO https://github.com/kavilo-bot/homebrew-tap/releases/latest/download/kavilo_windows_amd64.zip
```

> Darwin archives are currently **unsigned**. macOS Gatekeeper will *not*
> block binaries that arrived via `brew install`, `curl`, or `git`, but
> will warn if you download the `.zip` from a browser. See
> [Troubleshooting](#troubleshooting).

### Verify the install

```bash
kavilo --version
# → 🤖 kavilo v2.0.0-alpha.2

kavilo --help
```

## Quick start

```bash
# 1. Initialize ~/.kavilo/ (config, workspace, default skills, templates)
kavilo onboard

# 2. Add a provider API key — open ~/.kavilo/config.json and edit
#    "providers.<name>.apiKey". Common providers:
#
#    openrouter   https://openrouter.ai/keys
#    anthropic    https://console.anthropic.com/settings/keys
#    openai       https://platform.openai.com/api-keys
#    deepseek     https://platform.deepseek.com/api_keys
#    groq         https://console.groq.com/keys
#    gemini       https://aistudio.google.com/apikey

# 3. Talk to the assistant interactively
kavilo agent

# 4. Or one-shot
kavilo agent -m "What is the capital of France?"

# 5. Or run the long-lived service (chat channels, cron, heartbeat)
kavilo start
```

Out of the box `kavilo` ships with a sensible default model
(`anthropic/claude-opus-4-5` via OpenRouter). Override per call with
`KAVILO_MODEL=...` or persistently in `config.json` under
`agents.defaults.model`.

## Run as a background service

Homebrew installs a launchd / systemd service definition so you can keep
the runtime alive without a terminal session:

```bash
# Start now and on every login
brew services start kavilo

# Check status
brew services list | grep kavilo

# Tail the logs (default Homebrew paths)
tail -f $(brew --prefix)/var/log/kavilo.log
tail -f $(brew --prefix)/var/log/kavilo.err.log

# Stop
brew services stop kavilo

# Restart after editing ~/.kavilo/config.json
brew services restart kavilo
```

The service runs `kavilo start`, which spins up:

- the agent loop
- every channel marked `enabled: true` in `config.json`
- the cron scheduler reading `~/.kavilo/cron/jobs.json`
- the heartbeat scheduler driven by `workspace/HEARTBEAT.md`

If you'd rather run it ad-hoc, just run `kavilo start` in a terminal (or
inside `tmux` so it survives a disconnect).

## Configuration

All state lives under `~/.kavilo/`:

```
~/.kavilo/
├── config.json            ← settings, credentials, channels, MCP
├── workspace/             ← prompt files, skills, memory, sessions
│   ├── AGENTS.md          ← system prompt
│   ├── MEMORY.md          ← long-term memory
│   ├── HEARTBEAT.md       ← periodic tasks
│   └── skills/
├── mcp-auth/slack/        ← Slack MCP OAuth tokens (per alias)
├── cron/jobs.json         ← scheduled jobs
├── media/                 ← uploaded media cache
├── usage/                 ← token-usage rollups
├── logs/                  ← runtime logs
└── profiles/<name>/       ← isolated alternate homes (see Profiles)
```

### Minimal `config.json`

```json
{
  "agents": {
    "defaults": {
      "model": "anthropic/claude-opus-4-5",
      "provider": "auto",
      "maxTokens": 8192,
      "workspace": "~/.kavilo/workspace"
    }
  },
  "providers": {
    "openrouter": { "apiKey": "sk-or-..." },
    "anthropic":  { "apiKey": "sk-ant-..." },
    "openai":     { "apiKey": "sk-..." }
  },
  "runtime": {
    "heartbeat": { "enabled": true, "intervalS": 1800 }
  }
}
```

`provider: "auto"` picks the first provider with a configured key at
request time. To pin a single provider, set `agents.defaults.provider`
to one of: `openai`, `anthropic`, `openrouter`, `deepseek`, `groq`,
`gemini`, `dashscope`, `moonshot`, `minimax`, `ollama`, `vllm`,
`zhipu`, etc.

### Environment overrides

These shell-env vars **override** anything in `config.json` (process-wide,
not per-profile):

| Variable                  | Effect                                      |
|---------------------------|---------------------------------------------|
| `KAVILO_MODEL`            | Override `agents.defaults.model`            |
| `KAVILO_PROVIDER`         | Override `agents.defaults.provider`         |
| `KAVILO_API_KEY`          | Override the resolved provider's API key    |
| `KAVILO_API_BASE`         | Override the resolved provider's base URL   |
| `KAVILO_WORKSPACE`        | Override `agents.defaults.workspace`        |
| `KAVILO_HOME`             | Use a different `~/.kavilo` root            |
| `ANTHROPIC_API_KEY` etc.  | Pick up provider keys from the OS env       |

## Chat channels

`kavilo start` connects to every enabled channel. Each lives under
`channels.<name>` in `config.json` and has an `enabled` flag plus a
per-platform allow-list.

### Slack (Socket Mode — no public HTTPS)

```json
"channels": {
  "slack": {
    "enabled": true,
    "mode": "socket",
    "botToken": "xoxb-...",
    "appToken": "xapp-...",
    "groupPolicy": "mention",
    "allowFrom": ["U0123ABC"]
  }
}
```

DMs and `@bot` mentions become inbound prompts; replies post back into the
same thread. Socket Mode means **no port forwarding required**.

### Telegram

```json
"channels": {
  "telegram": {
    "enabled": true,
    "token": "12345:ABC...",
    "allowFrom": ["123456789"],
    "groupPolicy": "mention"
  }
}
```

### Discord

```json
"channels": {
  "discord": {
    "enabled": true,
    "token": "...",
    "allowFrom": ["705222568751267870"],
    "intents": 4609,
    "groupPolicy": "mention"
  }
}
```

Other supported channels (all opt-in via `enabled: true` in
`config.json`): `dingtalk`, `email`, `feishu`, `mochat`, `nanorelay`,
`qq`, `wecom`, `whatsapp`.

`groupPolicy` accepts `mention` (default — only respond when @-mentioned
in groups) or `all`. `allowFrom` is a per-platform allow-list of user IDs
or `["*"]` to allow everyone.

## MCP (Model Context Protocol)

### Use kavilo as an MCP server (e.g. in Cursor / Claude Desktop)

`kavilo mcp serve <name>` runs a built-in MCP server over stdio. Two
servers ship out of the box:

- **`self`** — exposes sessions, config, channels, MCP servers, cron
  jobs, and token usage. Sensitive fields (auth tokens, webhook secrets,
  API keys) are sanitized.
- **`slack`** — exposes search, post, history, users, and search-context
  tools against the workspace whose alias is configured.

Cursor / Claude Desktop entry:

```json
{
  "mcpServers": {
    "kavilo-self": {
      "command": "kavilo",
      "args": ["mcp", "serve", "self"]
    }
  }
}
```

### Connect kavilo to outbound MCP servers

Add entries under `tools.mcpServers` in `config.json`:

```json
"tools": {
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp", "--transport", "stdio"],
      "env": { "CONTEXT7_API_KEY": "ctx7sk-..." },
      "toolTimeout": 30,
      "enabledTools": ["resolve-library-id", "query-docs"]
    },
    "my-http-server": {
      "type": "http",
      "url": "https://example.com/mcp",
      "headers": { "Authorization": "Bearer ..." }
    }
  }
}
```

`stdio` and `streamable-http` transports are both supported.

### Slack MCP login

```bash
# Production (built-in client ID + hosted OAuth callback)
kavilo mcp slack login workspace-alias --team YOUR_TEAM_ID

# Development (your own dev Slack app, loopback callback)
kavilo mcp slack login dev \
    --client-id     YOUR_DEV_CLIENT_ID \
    --client-secret YOUR_DEV_CLIENT_SECRET \
    --redirect-uri  http://127.0.0.1:7898/oauth/callback

kavilo mcp slack status                    # all aliases
kavilo mcp slack status workspace-alias    # one alias
kavilo mcp slack logout workspace-alias    # revoke + delete
```

Tokens live under `~/.kavilo/mcp-auth/slack/<alias>.json` and are
injected only at runtime — never written to `config.json`.

## Profiles

Each profile is an isolated `KAVILO_HOME` directory with its own config,
sessions, MCP auth, cron jobs, and workspace.

```bash
kavilo profile use work        # sticky switch
kavilo profile show            # active profile + path
kavilo profile list            # all profiles
kavilo profile rm scratch      # delete (asks for confirmation)

# One-shot per-invocation override
kavilo --profile work agent
KAVILO_HOME=/path/to/home kavilo agent
```

Resolution order, evaluated **once at process start**:

1. `KAVILO_HOME` env (set explicitly or by `--profile`)
2. Sticky `~/.kavilo/active_profile`
3. The default `~/.kavilo/`

### What is and isn't isolated per profile

- **Per-profile** (`<KAVILO_HOME>/`): `config.json`, the workspace
  (sessions, AGENTS.md, skills, memory), Slack MCP tokens,
  `cron/jobs.json`, `media/`, `usage/`, `logs/`, CLI history.
- **Process-global**: provider env vars (`ANTHROPIC_API_KEY`,
  `OPENAI_API_KEY`, etc.), `KAVILO_*` overlays, the sticky profile file,
  the Slack OAuth loopback port (`127.0.0.1:7898`).

## Command reference

| Command                                            | Description                                                              |
|----------------------------------------------------|--------------------------------------------------------------------------|
| `kavilo onboard`                                   | Initialize `~/.kavilo/`                                                  |
| `kavilo agent`                                     | Interactive REPL with the agent                                          |
| `kavilo agent -m "msg"`                            | One-shot prompt                                                          |
| `kavilo start`                                     | Start enabled channels + cron + heartbeat                                |
| `kavilo status`                                    | Show config / data / workspace / daemon status                           |
| `kavilo version`                                   | Print version                                                            |
| `kavilo profile {use,show,list,rm}`                | Manage isolated `~/.kavilo/profiles/<name>/` homes                       |
| `kavilo mcp serve <self\|slack>`                   | Run a built-in MCP server over stdio                                     |
| `kavilo mcp slack {login,status,logout}`           | Manage Slack MCP OAuth aliases                                           |

All commands accept `--profile/-p <name>` to pin `KAVILO_HOME` for that
invocation.

## Upgrading

```bash
brew update
brew upgrade kavilo
brew services restart kavilo   # only if you run it as a service
```

## Uninstalling

```bash
brew services stop kavilo
brew uninstall kavilo
brew untap kavilo-bot/tap

# Optional: remove your data
rm -rf ~/.kavilo
```

## Troubleshooting

### `kavilo: command not found`

Check your `PATH` includes the Homebrew bin directory:

```bash
echo $PATH | tr ':' '\n' | grep -E '^/(opt/homebrew|usr/local)/bin$'
which kavilo
```

If `which kavilo` returns a stale path (e.g. an old `~/.cargo/bin/kavilo`),
either remove that copy or reorder your `PATH` so Homebrew comes first.

### `kavilo status` shows `daemon: stopped` but you ran `kavilo start`

The runtime writes a PID file at `~/.kavilo/gateway.pid` only on `kavilo
start`. If you started it inside another process manager (or it was
killed by `SIGHUP` when a terminal closed), the file may be missing. Use:

```bash
brew services list | grep kavilo
ps -ef | grep '[k]avilo start'
```

For a persistent foreground run, prefer:

```bash
brew services start kavilo      # recommended
# or
nohup kavilo start >> ~/.kavilo/logs/run.log 2>&1 &
```

### macOS "kavilo cannot be opened because the developer cannot be verified"

Darwin binaries in this tap are currently **unsigned**. Gatekeeper only
quarantines binaries that arrived with the
`com.apple.quarantine` extended attribute — typically because you
double-clicked a `.zip` from your browser. `brew install`, `curl`, and
`git` do **not** set that attribute, so binaries installed through them
run cleanly.

If you do hit the warning, clear it with:

```bash
xattr -dr com.apple.quarantine $(brew --prefix)/bin/kavilo
```

### Provider returns `401 Unauthorized` / `invalid api key`

Check `~/.kavilo/config.json` → `providers.<name>.apiKey`, and make sure
no shell env var (`OPENAI_API_KEY`, `KAVILO_API_KEY`, etc.) is overriding
it with a stale value:

```bash
env | grep -E '(KAVILO|API_KEY)' 
```

### Logs

| Source                           | Where                                          |
|----------------------------------|------------------------------------------------|
| `kavilo start` (via `brew services`) | `$(brew --prefix)/var/log/kavilo.{log,err.log}` |
| `kavilo start` (foreground)      | `~/.kavilo/logs/kavilo-<timestamp>.log`        |
| Per-session token usage          | `~/.kavilo/usage/`                             |

## Security & sandbox notes

- `tools.restrictToWorkspace` (default `true`) is a *correctness*
  boundary, not an adversarial one. It prevents `read_file` /
  `write_file` / `list_directory` / `glob_files` from touching paths
  outside the workspace, but the `shell` tool still runs `sh -c` with
  full host access.
- For untrusted execution, run `kavilo` itself inside a container, VM,
  or seccomp jail.
- `tools.exec.scrubEnv = true` (off by default) drops `*_API_KEY`,
  `*_API_TOKEN`, `*_SECRET`, and `KAVILO_*` from the `shell` tool's
  child env so the agent cannot exfiltrate provider credentials via
  `printenv`.
- Slack OAuth tokens live outside `config.json` under
  `~/.kavilo/mcp-auth/slack/` so backups of the config don't leak them.

## License

MIT — see [LICENSE](LICENSE).

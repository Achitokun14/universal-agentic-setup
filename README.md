# universal-agentic-setup

> One agent-neutral source of truth — rules, MCP servers, skills, tools — rendered
> into the native config of **26 coding agents** (18 wired automatically, 8 with
> printed instructions). Safe defaults, idempotent merges, no secrets in the repo.
> **Use any agent. Or all of them.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![PRs: only via review](https://img.shields.io/badge/PRs-owner%20review-blue)](CONTRIBUTING.md)
[![Status: stable](https://img.shields.io/badge/status-stable-green)](#status)

Formerly `claude-universal` (v1, Claude-Code-canonical, 7 CLIs). v2 is agent-neutral.
See [MIGRATION.md](MIGRATION.md) for the v1 → v2 path.

## Why

Every coding agent reads its own config files: `~/.claude/CLAUDE.md` here,
`~/.codex/AGENTS.md` and TOML there, `mcp.json` in five shapes, YAML where you
least want it. This repo keeps **one source of truth** — `core/` — and a sync
engine that renders it into each agent's native format:

- `core/AGENTS.md` — universal working rules, deployed as a managed block
- `core/mcp/servers.json` — MCP server catalog (12 servers, 6 default-enabled,
  env var **names** only — never values)
- `core/skills/catalog.json` — curated skill tiers (21 core / 14 optional / 9
  rejected-with-reason); skills are installed on demand via `npx skills`,
  the repo itself ships **zero vendored skills**
- `core/tools/catalog.json` — 8 core + 7 optional companion CLIs
- `agents/registry.json` — per-agent paths, MCP config format, detect hints,
  manual flags — every entry verified against vendor docs

What v2 does **not** do (honesty section): it does not mirror hooks or slash
commands into non-Claude agents (hook formats are agent-specific; the v1 deep
sync that did this was machine-bound and is retired), and it does not merge
YAML configs (Goose, Hermes) — those agents get printed instructions instead.

## Quick install — one command

```bash
git clone https://github.com/Achitokun14/universal-agentic-setup.git
cd universal-agentic-setup
./setup                 # PowerShell: .\setup.ps1
```

`./setup` (→ `setup.sh`) runs 8 phases: detect OS/agents → plan → confirm →
prereqs → Claude-rich user scope → skills → **wire every detected agent** → verify.
The agent wiring is `scripts/agentic_sync.py` — dry-run by default, idempotent
(re-running is a byte-identical no-op), reversible (`--uninstall` restores backups).

For just the agent-neutral sync, skip the orchestrator:

```bash
python3 scripts/agentic_sync.py                 # plan only (dry-run default)
python3 scripts/agentic_sync.py --apply         # write configs
python3 scripts/agentic_sync.py --list          # 26-agent registry table
python3 scripts/agentic_sync.py --doctor        # diagnostics
python3 scripts/agentic_sync.py --apply --skills  # + core skills via npx skills
```

For secrets, copy the gitignored templates first: `CREDS.md.template` → `CREDS.md`,
`SECRETS.md.template` → `SECRETS.md`. See [QUICKSTART.md](QUICKSTART.md).

## Supported agents

**18 wired automatically** (managed rules block + MCP merge in native format):
Claude Code · Codex · Gemini CLI · Antigravity · Cursor · GitHub Copilot ·
OpenCode · Amp · Cline · Windsurf/Devin · Kimi Code · Qwen Code · Crush ·
Factory Droid · Zed · omp · Junie · Amazon Q.

**8 manual** (printed instructions — YAML configs, GUI-managed MCP, or cloud-only):
Roo Code · Kilo Code · Goose · Aider · Warp · Hermes · OpenHands · Jules.
Exact reasons: [docs/AGENTS-MATRIX.md](docs/AGENTS-MATRIX.md) (generated from the registry).

MCP formats rendered: Claude `~/.claude.json` · Codex TOML `[mcp_servers.*]` ·
Gemini/Qwen settings.json · Cursor/Copilot/Junie/Factory/Kimi Code/omp/Cline/Amazon-Q
mcp.json-style · OpenCode `mcp` local|remote · Zed `context_servers` ·
Amp `amp.mcpServers` · Crush `mcp` · Antigravity/Windsurf `serverUrl` for remote.
Unrelated keys and user entries are always preserved; every modified file gets a
timestamped `.bak` first.

## What's included

### The Claude-canonical layer (v1 heritage, still maintained)

Deployed by `install.sh user` / `install.ps1` / `./setup` into `~/.claude/`:
settings deep-merge, docs, commands, hooks.

**10 hooks registered in `user/settings.json`** (11 hook scripts shipped plus
`skill-router.conf`; `session-context.sh` is shipped but intentionally unregistered):

| Event | Hook | What it does |
|---|---|---|
| `SessionStart` | `tool-inventory.sh` | Injects compact CLI/MCP/skill inventory |
| `UserPromptSubmit` | `skill-router.sh` | Token-thrifty intent → skill pointer |
| `PreToolUse(Edit\|Write)` | `block-secret-writes.sh` | Refuses writes to `.env`, `*.key`, etc. |
| `PreToolUse(Bash)` | `block-ai-attribution.sh` | Strips `Co-Authored-By:` AI lines from commits |
| `PostToolUse(Edit\|Write)` | `auto-format.sh` | Runs prettier/biome/ruff/rustfmt/gofmt |
| `PostToolUse(Bash\|Web*)` | `track-resources.sh` | Auto-maintains `useful-resources.md` |
| `PostToolUse(Web*)` | `entity-tracker.sh` | Graphiti-lite JSONL knowledge graph |
| `Stop` | `track-improvement.sh` | Updates per-project `IMPROVEMENT_STATE.json` |
| `Stop` | `notify-stop.sh` | Desktop notification when session ends |
| `Stop` | `memory-compiler.sh` | Compiles session insights to llm-wiki |

`user/settings.json` also enables **29 plugins** (of 30 listed; 1 disabled) via
`enabledPlugins` — Claude Code downloads and manages those itself.

**13 slash commands** (`user/commands/`): `/autoplan /careful /compress /crit
/extract /freeze /learn /pair /research /retro /unfreeze /wiki /ytdl`.

**Permissions in `user/settings.json`**: 85 allow · 19 deny · 22 ask patterns,
`defaultMode: "plan"`.

### Token-thrifty skill router

`user/hooks/skill-router.sh` runs on every prompt. Most prompts → 0 tokens.
Triggered prompts → ≤80 tokens of one-line skill pointers. The curated
`skill-router.conf` holds **37 keyword→skill triggers** across planning,
research, debugging, frontend, backend, ops, git, memory and skill-creation.
Compare to always-on injection (~300 tokens every prompt). Edit the conf to
tune; reloaded each prompt, no restart needed.

### MCP catalog (12 servers)

Default-enabled (keyless/local): `duckduckgo` `playwright` `fetch` `next-devtools`
`svelte` `vue-devtools` · Opt-in (key/binary/account): `firecrawl` `browserbase`
`github` `puppeteer` `lightpanda` `obsidian` — see
[`core/mcp/servers.json`](core/mcp/servers.json). Seeded exclusively from servers
this repo already documented in v1; env entries carry variable names only
(rendered as `${VAR}` placeholders). Note: the v1 README's "30+ MCPs" described
the author's workstation (see `user/docs/MCPS.md`); the catalog above is what
the repo actually ships.

### Skills catalog (21 core / 14 optional / 9 rejected)

`npx skills add <source> --skill <name> -g -y` installs from upstream repos —
full tables and skip rationale in [docs/SKILLS.md](docs/SKILLS.md).
(The v1 README's "358+ skills" described the author's machine; the repo ships a
catalog, not skills.)

### Local-model launchers (in `~/.local/bin/`)

```
gemma4      gemma4:e4b      9.6 GB    ✅ native tool_calls (best for goose agent loops)
qwen36      qwen3.6:27b     16 GB     ✅ native (disk-gated ≥ 22 GB)
llama4      llama4:16x17b   67 GB     ✅ native (disk-gated ≥ 80 GB)
bonsai      bonsai-8b-q4km  5.2 GB    ⚠️ chat-only (reasoning model, no tool_calls)
```

## Security stance

- **No secrets in this repo.** `CREDS.md` / `SECRETS.md` are gitignored;
  `*.template` versions show structure. MCP env entries are variable *names*.
- Secret-scan + path-leak-scan + shellcheck run in CI on every PR.
- `defaultMode: "plan"` — no silent code execution.
- `block-secret-writes.sh` refuses writes to credential-shaped files.
- `block-ai-attribution.sh` strips AI auth-coauthor lines from commits.
- Every config write is backup-first and reversible via `--uninstall`.
- See [SECURITY.md](SECURITY.md) for vulnerability reports.

## Repository docs

| File | Purpose |
|---|---|
| [README.md](README.md) | This file |
| [QUICKSTART.md](QUICKSTART.md) | 5-minute install path |
| [HOW-TO-USE.md](HOW-TO-USE.md) | Narrative manual |
| [ARCHITECTURE.md](ARCHITECTURE.md) | How the bundle is organised |
| [MIGRATION.md](MIGRATION.md) | v1 (`claude-universal`) → v2 |
| [docs/AGENTS-MATRIX.md](docs/AGENTS-MATRIX.md) | 26-agent matrix (generated) |
| [docs/SKILLS.md](docs/SKILLS.md) | Skill catalog tiers + rationale |
| [docs/TOOLS.md](docs/TOOLS.md) | CLI tools catalog |
| [CHANGELOG.md](CHANGELOG.md) | Latest versions (full history in `user/docs/CHANGELOG.md`) |
| [CONTRIBUTING.md](CONTRIBUTING.md) / [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) / [SECURITY.md](SECURITY.md) / [LICENSE](LICENSE) | Community + legal |
| [user/docs/](user/docs/) | Claude-layer references (RULES · SETTINGS · HOOKS · MCPS · …) |

## Status

| Component | Status |
|---|---|
| `agentic_sync.py` (26-agent engine) | Stable; 32-case unittest suite + smoke coverage |
| `install.sh user` / `project` | Stable, idempotent, dry-run supported |
| `setup` / `setup.sh` / `setup.ps1` | Stable (setup is a real file now, Windows-safe) |
| Skill router | Stable, validated in smoke tests |
| Local-model launchers | gemma4 + llama3.1 validated; qwen3.6 + llama4 untested (disk-gated) |
| Optional installers | All idempotent, all run from any cwd |

Tested on Linux (Debian/Ubuntu derivatives, Pop!_OS), macOS (same scripts, CI-verified),
and Windows (PowerShell entrypoint + CI job; Python 3.9+, stdlib only).

## Contributing

This is open source under MIT — fork and use freely. **Direct pushes to `main`
are owner-only.** To contribute upstream: fork, branch, PR. The owner reviews
every PR personally. See [CONTRIBUTING.md](CONTRIBUTING.md).

## Acknowledgements

The bundle integrates patterns from many excellent open-source projects:

- [obra/superpowers](https://github.com/obra/superpowers) — universal skill philosophy
- [garrytan/gstack](https://github.com/garrytan/gstack) — slash-command persona patterns
- [affaan-m/everything-claude-code](https://github.com/affaan-m/everything-claude-code) — instinct/learn skills
- [ChristopherKahler/{base,paul,carl}](https://github.com/ChristopherKahler) — workspace + planning + rule-injection frameworks
- [Yeachan-Heo/oh-my-claudecode](https://github.com/Yeachan-Heo/oh-my-claudecode) — agent orchestration
- [bmad-code-org/BMAD-METHOD](https://github.com/bmad-code-org/BMAD-METHOD) — multi-persona collaboration
- [microsoft/markitdown](https://github.com/microsoft/markitdown) — file → markdown conversion
- [Yakitrak/obsidian-cli](https://github.com/Yakitrak/obsidian-cli) — vault CLI (notesmd-cli)
- [StevenStavrakis/obsidian-mcp](https://github.com/StevenStavrakis/obsidian-mcp) — vault MCP server
- [google/langextract](https://github.com/google/langextract) — structured extraction
- [lightpanda-io/browser](https://github.com/lightpanda-io/browser) — fast headless browser
- [vercel-labs/skills](https://github.com/vercel-labs/skills) — the skills CLI the catalog builds on
- … and dozens more credited inline in `user/docs/INSPIRATIONS.md`.

Each upstream project retains its original license. The bundle scripts that orchestrate them are MIT.

## License

[MIT](LICENSE) — © 2026 Achitokun14

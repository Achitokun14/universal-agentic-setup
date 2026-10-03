# Quickstart — one command

## TL;DR

```bash
git clone https://github.com/Achitokun14/universal-agentic-setup.git
cd universal-agentic-setup
./setup
```

Done. The bundle detects your OS, your AI CLIs, your shell — and applies safe defaults everywhere. Re-runnable, idempotent, reversible.

## What `./setup` does

Eight phases, all logged to your terminal:

1. **Detect** — OS / arch / pkg-manager / shell / which agents you have (26-agent registry)
2. **Plan** — print exactly what would change; prompt once unless `--yes`
3. **Install prereqs** — `jq`, `python3`, `node`, `curl`, `git` via your pkg-manager (only what's missing)
4. **Apply user-scope** — merge `~/.claude/{settings.json,CLAUDE.md,docs,hooks,commands}` (idempotent — never clobbers your edits)
5. **Skills + scaffolding** — design-skill family, llm-wiki, improvement-state, useful-resources
6. **Wire every detected agent** — `agentic_sync.py`: rules block + MCP catalog in each agent's native format
7. **Manifest** — record version + install timestamp at `~/.universal-agentic-manifest.json`
8. **Verify** — smoke checks per agent; one PASS/FAIL line each

## Flags

| Flag | Purpose |
|---|---|
| `--dry-run` | Show plan; change nothing |
| `--yes` / `-y` | Skip prompts (auto-yes) |
| `--update` | `git pull --ff-only` + reapply |
| `--with=NAME[,NAME]` | Install opt-in add-ons (`obsidian`, `markitdown`, `lightpanda`, `ghidra`, `langextract`, `ollama`, `claw-code`, `warp`, `zrok`, `inspired`) |
| `--skip=STEP[,STEP]` | Skip steps (`skills`, `scaffolding`, `sync`) |
| `--only=user` | Only user-scope, skip skills/sync/add-ons |
| `--uninstall` | Restore latest `.bak`, remove bundle entries, leave your custom files alone |
| `--doctor` | Diagnose without changing anything |
| `--version` | Print version |
| `--help` | All flags |

## Common flows

### First-time install

```bash
git clone https://github.com/Achitokun14/universal-agentic-setup.git
cd universal-agentic-setup
./setup --dry-run                       # preview
./setup                                 # apply
```

### Headless / CI install

```bash
./setup --yes --with=obsidian,markitdown,langextract
```

### Install just the user-scope (no skills, no add-ons)

```bash
./setup --only=user
```

### Update later

```bash
./setup --update                        # git pull + reapply
```

### Diagnose without changing anything

```bash
./setup --doctor
```

Prints what's installed, what's missing, and one-line install hints for missing AI CLIs.

### Uninstall

```bash
./setup --uninstall
```

Restores the most recent `~/.claude/settings.json.bak.*`, strips managed blocks, removes managed MCP entries (restoring backups), removes bundle-owned hooks and docs. Custom files stay.

## Set up secrets

```bash
cp CREDS.md.template CREDS.md       # env-var inventory
cp SECRETS.md.template SECRETS.md   # storage cookbook (Bitwarden, 1Password, Keychain, etc.)
$EDITOR CREDS.md SECRETS.md
```

Both files are gitignored — they live on your machine, not in the repo.

Add at minimum to `~/.zshrc` (or your shell rc):

```bash
export MINIMAX_API_KEY="<your aggregator key>"   # used by goose planner, claw, kimi/opencode
export GEMINI_API_KEY="<your google key>"        # used by gemini-cli, /extract skill
```

…then `source ~/.zshrc`.

## Per-agent install (do this once if you don't have them)

`./setup` doesn't auto-install the agents — those are your choices. A few popular
ones (full 26-agent list with vendors and docs: `docs/AGENTS-MATRIX.md`):

```bash
# Claude Code — https://code.claude.com/docs/en/setup
# Codex
npm install -g @openai/codex
# Gemini CLI
npm install -g @google/gemini-cli
# OpenCode
curl -fsSL https://opencode.ai/install | sh
# Amp
curl -fsSL https://ampcode.com/install.sh | sh
# omp (oh-my-pi)
curl -fsSL https://omp.sh/install | sh
```

Then run `./setup` again — it'll detect the new agents and wire them.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `./setup: Permission denied` | `chmod +x setup setup.sh lib/*.sh` |
| `error: jq not found` | `./setup` will install it — say yes when prompted, or run your pkg-manager manually |
| Goose returns 401 | Check `GOOSE_OPENAI_API_KEY` in `~/.config/goose/config.yaml` is the literal value (Goose YAML doesn't shell-expand) |
| Claude doesn't see new skills | Restart Claude Code (skills register at session-start) |
| Hook isn't firing | `chmod +x ~/.claude/hooks/*.sh` and re-run `./setup --doctor` |
| `obsidian-cli: command not found` | `./setup --with=obsidian` and ensure `~/.local/bin` is on `PATH` |

For deeper details: [HOW-TO-USE.md](HOW-TO-USE.md), [ARCHITECTURE.md](ARCHITECTURE.md), per-tool docs in `user/docs/`.

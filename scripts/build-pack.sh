#!/usr/bin/env bash
# build-pack.sh — Build ~/Desktop/AI-CODING-AGENTS-PACK.zip from current config state.
#
# Includes: bundle, skills catalog, references, redacted config snapshots, install scripts.
# Excludes: _inspired repo clones (661M), whisper venv, lightpanda binary, API keys/tokens.

set -euo pipefail

DEST="$HOME/Desktop/AI-CODING-AGENTS-PACK.zip"
STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT

say() { printf '▸ %s\n' "$*"; }
REDACT='REDACTED_SET_VIA_ENV'

# ─── 1. bundle (claude-universal) ──────────────────────────────────
say "staging claude-universal bundle"
mkdir -p "$STAGE/claude-universal"
rsync -a --exclude='__pycache__' --exclude='*.pyc' \
  "$HOME/Desktop/ACTIVITIES/claude-universal/" "$STAGE/claude-universal/"

# ─── 2. catalog + inventory ────────────────────────────────────────
say "staging catalog + inventory"
cp "$HOME/Desktop/ACTIVITIES/SKILLS-CATALOG.md" "$STAGE/" 2>/dev/null || true
cp "$HOME/Desktop/ACTIVITIES/skills-inventory.json" "$STAGE/" 2>/dev/null || true

# ─── 3. references (small) ─────────────────────────────────────────
if [[ -d "$HOME/Desktop/ACTIVITIES/references" ]]; then
  say "staging references"
  mkdir -p "$STAGE/references"
  cp -a "$HOME/Desktop/ACTIVITIES/references/." "$STAGE/references/"
fi

# ─── 4. per-tool config snapshots (redacted) ───────────────────────
say "staging config snapshots (redacting secrets)"
mkdir -p "$STAGE/configs"/{claude,goose,codex,gemini,kimi,opencode,claw}

# claude: CLAUDE.md + commands + hooks + settings template (no secrets — already hook-safe)
cp "$HOME/.claude/CLAUDE.md" "$STAGE/configs/claude/" 2>/dev/null || true
cp "$HOME/.claude/AGENTS.md" "$STAGE/configs/claude/" 2>/dev/null || true
mkdir -p "$STAGE/configs/claude/commands" "$STAGE/configs/claude/hooks" "$STAGE/configs/claude/docs"
cp -a "$HOME/.claude/commands/." "$STAGE/configs/claude/commands/" 2>/dev/null || true
cp -a "$HOME/.claude/hooks/." "$STAGE/configs/claude/hooks/" 2>/dev/null || true
cp -a "$HOME/.claude/docs/." "$STAGE/configs/claude/docs/" 2>/dev/null || true

# Redact settings.json (remove credentials/auth fields just in case)
if [[ -f "$HOME/.claude/settings.json" ]]; then
  python3 - "$HOME/.claude/settings.json" "$STAGE/configs/claude/settings.json.template" <<'PY'
import json, sys
d = json.load(open(sys.argv[1]))
# Strip any API-key-shaped values recursively
def scrub(obj):
    if isinstance(obj, dict):
        return {k: ('REDACTED_SET_VIA_ENV' if any(s in k.lower() for s in ['key','token','secret','password']) else scrub(v)) for k,v in obj.items()}
    if isinstance(obj, list): return [scrub(x) for x in obj]
    if isinstance(obj, str) and (obj.startswith(('sk-','ghp_','xoxb-','AKIA','AIza'))):
        return 'REDACTED_SET_VIA_ENV'
    return obj
json.dump(scrub(d), open(sys.argv[2],'w'), indent=2)
PY
fi

# goose: config.yaml — aggressively redact (we know the plaintext API key is there)
if [[ -f "$HOME/.config/goose/config.yaml" ]]; then
  sed -E \
    -e 's/(GOOSE_OPENAI_API_KEY:).*/\1 REDACTED_SET_VIA_ENV/' \
    -e 's/(API_KEY[A-Z_]*:).*/\1 REDACTED_SET_VIA_ENV/' \
    -e 's/(sk-[A-Za-z0-9_-]{10,})/REDACTED_SET_VIA_ENV/g' \
    "$HOME/.config/goose/config.yaml" > "$STAGE/configs/goose/config.yaml.template"
fi
cp "$HOME/.config/goose/mcp.json" "$STAGE/configs/goose/" 2>/dev/null || true
cp -a "$HOME/.config/goose/hooks" "$STAGE/configs/goose/" 2>/dev/null || true
# Goose skills — links only (not full content, save space)
ls "$HOME/.config/goose/skills/" 2>/dev/null > "$STAGE/configs/goose/skills-list.txt" || true

# codex: config.toml redacted
if [[ -f "$HOME/.codex/config.toml" ]]; then
  sed -E 's/(api_key[[:space:]]*=[[:space:]]*)"[^"]*"/\1"REDACTED_SET_VIA_ENV"/' \
    "$HOME/.codex/config.toml" > "$STAGE/configs/codex/config.toml.template"
fi
ls "$HOME/.codex/skills/" 2>/dev/null > "$STAGE/configs/codex/skills-list.txt" || true
cp -a "$HOME/.codex/commands" "$STAGE/configs/codex/" 2>/dev/null || true

# gemini
cp "$HOME/.gemini/GEMINI.md" "$STAGE/configs/gemini/" 2>/dev/null || true
if [[ -f "$HOME/.gemini/settings.json" ]]; then
  python3 - "$HOME/.gemini/settings.json" "$STAGE/configs/gemini/settings.json.template" <<'PY'
import json, sys
d = json.load(open(sys.argv[1]))
def scrub(obj):
    if isinstance(obj, dict):
        return {k: ('REDACTED_SET_VIA_ENV' if any(s in k.lower() for s in ['key','token','secret','password']) else scrub(v)) for k,v in obj.items()}
    if isinstance(obj, list): return [scrub(x) for x in obj]
    return obj
json.dump(scrub(d), open(sys.argv[2],'w'), indent=2)
PY
fi
cp -a "$HOME/.gemini/commands" "$STAGE/configs/gemini/" 2>/dev/null || true

# kimi: config.toml redacted
if [[ -f "$HOME/.kimi/config.toml" ]]; then
  sed -E \
    -e 's/(api_key[[:space:]]*=[[:space:]]*)"[^"]*"/\1"REDACTED_SET_VIA_ENV"/' \
    "$HOME/.kimi/config.toml" > "$STAGE/configs/kimi/config.toml.template"
fi
cp "$HOME/.kimi/mcp.json" "$STAGE/configs/kimi/" 2>/dev/null || true

# opencode
cp "$HOME/.config/opencode/opencode.json" "$STAGE/configs/opencode/" 2>/dev/null || true
cp "$HOME/.config/opencode/AGENTS.md" "$STAGE/configs/opencode/" 2>/dev/null || true
cp -a "$HOME/.config/opencode/agent" "$STAGE/configs/opencode/" 2>/dev/null || true

# claw: env.sh template + models.md (no secrets — template already)
cp -a "$HOME/.config/claw" "$STAGE/configs/" 2>/dev/null || true

# ─── 4a. Standalone launchers from ~/.local/bin ─────────────────
mkdir -p "$STAGE/local-bin"
for script in bonsai reinstall-bonsai gemma4 qwen36 llama4; do
  if [[ -f "$HOME/.local/bin/$script" ]]; then
    cp "$HOME/.local/bin/$script" "$STAGE/local-bin/$script.sh"
  fi
done
[[ -d "$STAGE/local-bin" ]] && echo "  ✓ local-bin launchers bundled: $(ls $STAGE/local-bin/ | wc -l)"

cat > "$STAGE/local-bin/README.md" <<'LBR'
# Local Bin Launchers

Five shell launchers wrapping `goose session` with different local Ollama chat models.
All use MiniMax-M2 (aggregator) as the planner.

| Script | Chat model (default) | Size | Tool-calling | Notes |
|---|---|---|---|---|
| `gemma4.sh` | `gemma4:e4b` | ~9.6 GB | ✅ native (cleanest) | Google Gemma 4 e4b. Best default for Goose agent loops. |
| `qwen36.sh` | `qwen3.6:27b` | ~16 GB | ✅ native (untested) | Alibaba Qwen 3.6 27b. Disk gate ≥ 22 GB. |
| `llama4.sh` | `llama4:16x17b` | ~67 GB | ✅ native (untested) | Meta Llama 4 MoE. Disk gate ≥ 80 GB. |
| `bonsai.sh` | `bonsai-8b-q4km` (custom from bartowski) | ~5 GB | ❌ reasoning-only | CHAT ONLY — emits long think-tokens, no tool_calls. Do not use for agent loops. |
| `reinstall-bonsai.sh` | — | — | — | Helper. Rebuilds `bonsai-8b-q4km` at chosen quant. `--quant Q4_K_M\|Q5_K_M\|Q6_K\|Q8_0`. |

## Install

```bash
mkdir -p ~/.local/bin
for s in bonsai gemma4 qwen36 llama4 reinstall-bonsai; do
  cp local-bin/$s.sh ~/.local/bin/$s
  chmod +x ~/.local/bin/$s
done
```

Ensure `~/.local/bin` is on PATH (zshrc: `export PATH="$HOME/.local/bin:$PATH"`).

## Run

```bash
bonsai           # default bonsai-8b-q4km
gemma4           # default gemma4:e4b
qwen36           # default qwen3.6:27b (auto-pulls)
llama4           # default llama4:16x17b (auto-pulls — needs 80 GB free)
```

## Env overrides

```bash
BONSAI_MODEL=bonsai-8b-q5km:latest bonsai
GEMMA4_MODEL=gemma4:e2b gemma4
QWEN36_MODEL=qwen3.6:latest qwen36
LLAMA4_MODEL=llama3.3:70b llama4
# Shared planner overrides:
BONSAI_PLANNER_MODEL=GLM-4.5  bonsai
```

## Prereqs

- Ollama running (`ollama serve`, or launchers auto-start it).
- Goose installed (`curl -fsSL https://block.github.io/goose/install.sh | sh`).
- MiniMax key exported for planner (`export MINIMAX_API_KEY=...` in shell rc).
LBR

# ─── 4b. Extra config snapshots for new tools ────────────────────
# CARL
if [[ -d "$HOME/.carl" ]]; then
  mkdir -p "$STAGE/configs/carl"
  cp "$HOME/.carl/carl.json" "$STAGE/configs/carl/" 2>/dev/null || true
fi
# BASE (workspace data is per-project; only capture global install marker)
if [[ -d "$HOME/.base" ]]; then
  mkdir -p "$STAGE/configs/base"
  # Only copy operator profile + schemas — skip transient data/ and grooming/
  cp "$HOME/.base/operator.json" "$STAGE/configs/base/" 2>/dev/null || true
  cp -a "$HOME/.base/schemas" "$STAGE/configs/base/" 2>/dev/null || true
fi
# PAUL (per-project; just record install marker)
[[ -f "$HOME/.claude/commands/paul/init.md" ]] && touch "$STAGE/configs/.paul-installed"

# Zeroclaw config (with tunnel info), redact API keys
if [[ -f "$HOME/.zeroclaw/config.toml" ]]; then
  mkdir -p "$STAGE/configs/zeroclaw"
  sed -E 's/(api_key[[:space:]]*=[[:space:]]*)"[^"]*"/\1"REDACTED_SET_VIA_ENV"/g; s/enc2:[a-f0-9]+/REDACTED_ENCRYPTED_TOKEN/g' \
    "$HOME/.zeroclaw/config.toml" > "$STAGE/configs/zeroclaw/config.toml.template"
fi

# ─── 5. INSTALL.md — how to restore from this pack ────────────────
cat > "$STAGE/INSTALL.md" <<'INSTALL'
# AI Coding Agents Pack — Install

Portable snapshot of a fully-configured AI-agent workstation. Restore on any machine.

## What's inside

```
claude-universal/          — the bundle (scripts + user/ + project/ templates)
configs/                   — per-tool config snapshots (redacted)
  claude/      goose/      codex/      gemini/      kimi/      opencode/      claw/
  carl/        base/       zeroclaw/                                    (newer)
SKILLS-CATALOG.md          — ranked + categorized index of 1,488 skills
skills-inventory.json      — machine-readable skill index
references/                — non-skill clones (W3C specs, etc.)
```

## Restore steps

### 1. Install the bundle (user scope)

```bash
cd claude-universal
./install.sh user
./install-skills.sh            # design skill family (Emil/Taste/Impeccable/UI-UX-Pro-Max)
./scripts/init-llm-wiki.sh
./scripts/init-improvement-state.sh
./scripts/bootstrap-resources.sh
```

### 2. Install each coding CLI (interactively where needed)

```bash
# Claude Code:      https://docs.claude.com/claude-code     # npm or bun
# Kimi CLI:         pip install kimi-cli                     # or per moonshot docs
# OpenCode:         curl -fsSL https://opencode.ai/install | sh
# Gemini CLI:       npm install -g @google/gemini-cli
# Goose:            curl -fsSL https://block.github.io/goose/install.sh | sh
# Codex:            npm install -g @openai/codex
# Claw Code:        bash claude-universal/scripts/install-claw-code.sh
# Ollama:           curl -fsSL https://ollama.com/install.sh | sh
# Lightpanda:       bash claude-universal/scripts/install-lightpanda.sh
# zrok (replaces ngrok): bash claude-universal/scripts/install-zrok.sh
# Ghidra + MCP:     bash claude-universal/scripts/install-ghidra.sh
# BASE/PAUL/CARL:   bash claude-universal/scripts/install-inspired.sh (interactive)
```

### 3. Apply the configs

```bash
# Claude
cp -a configs/claude/commands    ~/.claude/
cp -a configs/claude/hooks       ~/.claude/
cp -a configs/claude/docs        ~/.claude/
cp    configs/claude/CLAUDE.md   ~/.claude/
cp    configs/claude/AGENTS.md   ~/.claude/
# settings.json.template → review + fill secrets → write to ~/.claude/settings.json

# Goose
cp    configs/goose/mcp.json     ~/.config/goose/
cp -a configs/goose/hooks        ~/.config/goose/
# config.yaml.template → set your MINIMAX_API_KEY + write to ~/.config/goose/config.yaml

# Gemini
cp    configs/gemini/GEMINI.md   ~/.gemini/
cp -a configs/gemini/commands    ~/.gemini/
# settings.json.template → your MCP + auth → write to ~/.gemini/settings.json

# OpenCode
cp    configs/opencode/opencode.json ~/.config/opencode/
cp    configs/opencode/AGENTS.md     ~/.config/opencode/
cp -a configs/opencode/agent         ~/.config/opencode/

# Kimi
# config.toml.template → your MINIMAX_API_KEY → write to ~/.kimi/config.toml
cp    configs/kimi/mcp.json      ~/.kimi/

# Codex
# config.toml.template → write to ~/.codex/config.toml
cp -a configs/codex/commands     ~/.codex/

# Claw
cp -a configs/claw               ~/.config/
```

### 4. Export secrets in your shell profile (NEVER in configs)

```bash
# ~/.zshrc  (or ~/.bashrc)
export MINIMAX_API_KEY="sk-cp-..."                # aggregator key
export CLAW_API_KEY="$MINIMAX_API_KEY"
export CLAW_API_BASE_URL="https://api.minimaxi.chat/v1"
export ANTHROPIC_API_KEY="sk-ant-..."             # if using Anthropic direct
export GEMINI_API_KEY="..."                        # for langextract + extract
export OLLAMA_HOST="https://ollama.com"
```

### 5. Cross-tool sync (refresh all at once)

```bash
python3 claude-universal/scripts/agentic_sync.py --apply   # 26-agent rules + MCP sync
```

### 6. Verify

```bash
claude --version  kimi --version  opencode --version  gemini --version
goose --version   codex --version  claw --version
bash claude-universal/scripts/scan-skills.sh                # rebuild inventory
```

## What's NOT in this pack

| Item | Why excluded | How to get |
|---|---|---|
| `~/.claude/skills/_inspired/` (661 MB) | 9 cloned OSS repos — too heavy | `bash claude-universal/scripts/install-inspired.sh --all` |
| Whisper venv (200+ MB) | Rebuilt at install time | `bash claude-universal/scripts/install-claw-code.sh` (handled) |
| Lightpanda binary (119 MB) | Architecture-specific | `bash claude-universal/scripts/install-lightpanda.sh` |
| API keys | Security | You provide via env vars (step 4) |
| Plugin-provided skills | Installed via marketplace | Handled by Claude Code plugin system |

## License notes

- Bundle scripts: MIT (see claude-universal/LICENSE if present; otherwise public domain)
- Inspired repos: each retains its original license (clone via install-inspired.sh)
- Skills: each plugin retains its original license
INSTALL

# ─── 6. PACK-README.md ─────────────────────────────────────────────
cat > "$STAGE/PACK-README.md" <<'README'
# AI Coding Agents Pack

Snapshot built from a fully-configured agent workstation.

Supports 7 coding CLIs in parallel:
Claude Code · Kimi · OpenCode · Gemini CLI · Goose · Codex · Claw Code

Plus cross-tool shared resources (MCPs, hooks, commands, skills catalog, rules).

Full restore instructions: see `INSTALL.md`.

Built: $(date -u +%Y-%m-%dT%H:%M:%SZ)
README

# ─── 7. zip it ─────────────────────────────────────────────────────
say "zipping → $DEST"
rm -f "$DEST"
(cd "$STAGE" && zip -qr "$DEST" . -x '*.pyc' -x '__pycache__/*' -x '*/_inspired/*')

echo
echo "✓ pack built: $DEST ($(du -sh "$DEST" | cut -f1))"
unzip -l "$DEST" | tail -5

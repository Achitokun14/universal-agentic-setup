# Architecture

## Goal

One portable bundle that brings 7 AI coding CLIs to feature parity on a workstation, without forcing you to use any of them. Each CLI keeps its native config format; the bundle deploys consistent rules, skills, MCPs, and hooks across all of them.

## Layout

```
claude-universal/
├── install.sh                 # main installer (bash)
├── install.ps1                # PowerShell mirror (Windows)
├── install-skills.sh          # design-skill family installer
├── HOW-TO-USE.md              # narrative manual
├── QUICKSTART.md              # 5-min path
├── ARCHITECTURE.md            # this file
├── README.md                  # repo landing page
│
├── user/                      # GLOBAL scope — deploys to ~/.claude/
│   ├── CLAUDE.md              # universal rules (managed block)
│   ├── AGENTS.md              # cross-tool mirror (symlinked at install)
│   ├── settings.json          # safe defaults, deep-merged not overwritten
│   ├── .gitignore             # used as project-template too
│   ├── hooks/                 # 11 hooks (post-tool, stop, prompt-submit)
│   │   ├── auto-format.sh
│   │   ├── block-ai-attribution.sh
│   │   ├── block-secret-writes.sh
│   │   ├── entity-tracker.sh
│   │   ├── memory-compiler.sh
│   │   ├── notify-stop.sh
│   │   ├── session-context.sh
│   │   ├── skill-router.sh    # token-thrifty intent → skill suggestion
│   │   ├── skill-router.conf  # editable trigger map
│   │   ├── tool-inventory.sh
│   │   ├── track-improvement.sh
│   │   └── track-resources.sh
│   ├── commands/              # 13 slash commands (/wiki, /learn, /plan, ...)
│   └── docs/                  # detailed per-area references
│       ├── RULES.md  SETTINGS.md  HOOKS.md  MCPS.md  SKILLS.md
│       ├── ACPS.md  COMMANDS.md  PLUGINS.md  WEB-FALLBACK.md
│       ├── DEPLOYMENT.md  INSPIRATIONS.md  LLM-WIKI.md
│       └── README.md  AGENTS.md  CHANGELOG.md
│
├── project/                   # PER-REPO scope — copies into <repo>/
│   ├── CLAUDE.md              # minimal "overrides only" template
│   ├── AGENTS.md
│   └── .claude/
│       ├── settings.json      # tighter than user-scope
│       ├── agents/            # scaffolding (.gitkeep)
│       ├── commands/          # scaffolding (.gitkeep)
│       └── hooks/             # examples (run-tests-before-commit.sh.example)
│
└── scripts/                   # optional installers + sync utilities
    ├── build-pack.sh                  # build portable workstation .zip
    ├── bootstrap-resources.sh         # seed useful-resources.md autotracker
    ├── generate-skills-catalog.py     # render SKILLS-CATALOG.md from inventory
    ├── init-improvement-state.sh      # IMPROVEMENT_STATE.json scaffolding
    ├── init-llm-wiki.sh               # llm-wiki/ directory scaffolding
    ├── install-claw-code.sh           # Claw Code aggregator router
    ├── install-ghidra.sh              # Ghidra + GhidraMCP
    ├── install-inspired.sh            # BASE/PAUL/CARL/superpowers menu
    ├── install-langextract.sh
    ├── install-lightpanda.sh
    ├── install-markitdown.sh          # Microsoft markitdown
    ├── install-obsidian.sh            # obsidian-cli + 6-agent obsidian-mcp wiring
    ├── install-ollama.sh
    ├── install-warp.sh                # cc/kc/oc/cw shell aliases
    ├── install-zrok.sh                # ngrok replacement
    ├── prune-skills.sh                # safe Tier-D skill disabler (move not delete)
    ├── agentic_sync.py                # v2 agent-neutral sync engine (rules + MCP merge, 26 agents)
    ├── scan-skills.sh                 # rebuild skills-inventory.json
    ├── vw-helper.sh                   # Vaultwarden/Bitwarden helper
    ├── ytdl-to-wiki.sh                # yt-dlp → whisper → wiki
    └── zrok-share.sh                  # zrok tunnel sharing
```

## Install modes

### `install.sh user` — global

Idempotent merge into `~/.claude/`:

| Asset | Strategy |
|---|---|
| `settings.json` | Deep JSON merge; arrays deduped; existing scalars preserved |
| `CLAUDE.md`, `AGENTS.md` | Managed-block replace-or-append (your content untouched) |
| `hooks/*.sh` | Added if absent; existing hook files preserved |
| `commands/*.md` | Always refreshed from bundle |
| `docs/*.md` | Always refreshed from bundle |
| `.gitignore` | Append missing entries only |

Run `install.sh --dry-run user` to preview every action before committing.

### `install.sh project /path/to/repo` — per-repo

Same merge logic, scoped to `<repo>/CLAUDE.md` and `<repo>/.claude/`. The project template is intentionally minimal — only fields that *must* differ from user defaults belong there.

## Cross-tool architecture

Each AI coding CLI has its own native config format. The bundle ships canonical sources at `user/` and provides per-tool sync scripts:

| CLI | Native format | Synced via |
|---|---|---|
v2 replaces the v1 per-tool sync scripts with one agent-neutral engine:

```bash
python3 scripts/agentic_sync.py            # dry-run plan (default)
python3 scripts/agentic_sync.py --apply    # write configs
```

It wires **26 agents** (see `docs/AGENTS-MATRIX.md`): managed rules block from
`core/AGENTS.md` + MCP servers from `core/mcp/servers.json` in each agent's native
format, preserving unrelated keys and user entries. The engine is **idempotent** —
running twice yields byte-identical state. It never overwrites user-edited entries;
existing managed entries are updated in place.

## Hook event flow (Claude Code)

```
session start
  ↓
SessionStart hook → tool-inventory.sh prints CLI/MCP inventory
  ↓
user submits prompt
  ↓
UserPromptSubmit hooks (run in order):
  • carl-hook.py    — context-bracket rule injection
  • skill-router.sh — keyword → skill suggestion (≤80 tokens, dedup)
  ↓
model reasons + uses tools
  ↓
PreToolUse hooks (per-tool matchers)
  ↓
tool runs
  ↓
PostToolUse hooks (per-tool matchers):
  • track-resources.sh   — Bash/WebFetch/WebSearch
  • auto-format.sh       — Edit/Write/MultiEdit (runs prettier/biome/etc)
  • entity-tracker.sh    — WebFetch/WebSearch (graphiti-lite)
  • block-secret-writes.sh — Edit/Write (refuse if secret-shaped)
  • block-ai-attribution.sh — Edit/Write (strip Co-Authored-By: Claude)
  ↓
Stop hooks (session end):
  • track-improvement.sh — IMPROVEMENT_STATE.json update
  • notify-stop.sh       — desktop notification
  • memory-compiler.sh   — wiki entry from session
```

## Skill router (token economics)

The `skill-router.sh` hook is the bundle's signature feature. Most "rule-injection" hooks (BASE, etc.) emit ~300 tokens *every prompt*. Skill router emits **0 tokens** when no trigger fires (most prompts) and capped at **~80 tokens** when triggers match. Net savings: 70-100% per prompt vs. always-on injection.

Triggers live in `user/hooks/skill-router.conf` — one line per rule, format `extended-regex|||skill_name|||one-line purpose`. Edit freely; reloaded each prompt.

## Build pack (portable workstation snapshot)

`scripts/build-pack.sh` produces a redacted ~1.3 MB zip containing:

- The full bundle (this repo)
- A snapshot of each agent's live config (with secrets stripped)
- 5 local-model launchers (`gemma4`, `qwen36`, `llama4`, `bonsai`, `reinstall-bonsai`)
- 60+ install scripts and helpers
- The full `INSTALL.md` for restoring on a new machine

Output: `~/Desktop/AI-CODING-AGENTS-PACK.zip`. The companion `AI-CODING-MODELS-PACK.zip` (8 KB) ships model recipes (not binaries — those pull on-demand).

## Why the bundle exists (design rationale)

1. **One source of truth.** Edit rules in `user/CLAUDE.md`, hooks in `user/hooks/`, MCPs in one config — they propagate everywhere.
2. **Idempotent merges.** Running the installer twice never breaks anything. Backups go to `*.bak.<timestamp>`.
3. **Plain text, no daemons.** No background processes; no opaque binary configs. You can read every file the bundle creates.
4. **Per-CLI native formats preserved.** No lowest-common-denominator translator. Each tool gets its native format.
5. **Token-conscious.** Hooks default to silent. Skills are linked, not inlined. Catalog tiering (S/A/B/C/D) prevents palette bloat.

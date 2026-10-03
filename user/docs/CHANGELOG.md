# Changelog

All notable changes to the `universal-agentic-setup` bundle (v1 name: `claude-universal`). Format: [Keep a Changelog](https://keepachangelog.com), semver.

## [2.0.0] — 2026-10-03

Renamed `claude-universal` → `universal-agentic-setup`: agent-neutral core
(`core/`), 26-agent registry (`agents/registry.json`), sync engine
(`scripts/agentic_sync.py`, dry-run default / idempotent / reversible), real
`setup` script + `setup.ps1`, generated `docs/AGENTS-MATRIX.md`, unittest suite,
windows CI. BREAKING: managed-block markers and manifest renamed — uninstall v1
first (see MIGRATION.md); `sync-cross-tool*.sh` removed; `user/AGENTS.md`
superseded by `core/AGENTS.md`. Details mirrored in the root [CHANGELOG.md](../../CHANGELOG.md).

## [1.18.0] — 2026-04-26

### Added — one-command universal `./setup`

Single entrypoint replacing the previous "run install.sh, then install-skills.sh, then init-llm-wiki.sh, then ..." chain. Detects host environment, plans changes, prompts once, applies idempotently. Re-running is a safe no-op. Updateable (`--update` does git pull + reapply). Reversible (`--uninstall` restores latest .bak and strips bundle entries).

**Flags:**
`--dry-run` · `--yes` / `-y` · `--update` · `--uninstall` · `--doctor` · `--with=NAME[,NAME]` · `--skip=STEP[,STEP]` · `--only=user` · `--version` · `--help`

**Architecture:**
- `setup.sh` (~280 lines, orchestration only — never duplicates logic)
- `lib/ui.sh` — colors, prompts, dry-run wrapper
- `lib/detect.sh` — OS / arch / pkg-manager / shell / AI CLIs / bundle state (fresh vs installed)
- `lib/deps.sh` — install missing prereqs (jq, python3, node, curl, git) per OS
- `lib/plan.sh` — pretty-print the change plan
- `lib/apply.sh` — wraps existing install.sh + install-skills.sh + sync-cross-tool* + add-on installers
- `lib/verify.sh` — post-install smoke checks; doctor-mode adds suggestions for missing CLIs
- `VERSION` file at repo root — single source-of-truth read by setup, install.sh, CI verify-step
- Manifest at `~/.claude/.claude-universal-manifest.json` records `{version, installed_at, bundle_dir, addons, host}`. Drives update detection + clean uninstall.

**OS detection matrix:**
| Linux distros | macOS | WSL | Windows native |
|---|---|---|---|
| ubuntu / debian / fedora / rhel / arch / opensuse / alpine (auto-detected) | brew | inherits linux | `setup.ps1` mirror (Phase 4 — pending) |

**Existing scripts unchanged** — setup.sh is pure orchestration. Power users can still call `install.sh user` / `install-skills.sh` / `scripts/install-obsidian.sh` directly.

### CI + tests
- `.github/workflows/lint.yml` — shellcheck (fail), shfmt (advisory), secret-scan, path-leak-scan
- `.github/workflows/smoke.yml` — Ubuntu + macOS matrix; runs `./setup --version|--help|--doctor|--dry-run` and `tests/smoke.sh`
- `tests/smoke.sh` — 15-assertion suite (currently 15/15 passing locally)
- VERSION ↔ CHANGELOG consistency check in CI

### Fixed
- **`notify-stop.sh`** — cross-OS implementation. Linux uses `notify-send`, macOS uses `osascript`, Windows/Cygwin/MSYS uses PowerShell. Silently no-ops if no notifier is available.
- **`skill-router.sh`** — `ROUTER_CONF` falls back to `<script-dir>/skill-router.conf` if `~/.claude/hooks/skill-router.conf` is absent. Lets fresh installs and isolated-HOME tests work.
- **`install-inspired.sh:183`** — removed misleading `# TODO: actual selection` comment; the `skills-selective` case correctly falls through to `surface_skills`.
- **`/etc/os-release` sourcing** — wrapped in subshell so its `VERSION=...` doesn't clobber our bundle's `VERSION` env var (was causing `./setup` final banner to show OS version instead of bundle version).

### Tooling / contributor experience
- `.shellcheckrc` — disables SC2086, SC1091, SC2155, SC2154 (justified inline)
- `.editorconfig` — 2-space, LF, UTF-8, except .ps1 (CRLF, 4-space)
- `install.sh` — reads `VERSION`, supports `--version` and `--help`, banner shows version
- `tests/` directory for ongoing test suites
- README + QUICKSTART rewritten to lead with `./setup`

### Verification
- 15/15 smoke tests pass against isolated `$HOME` fixture
- `./setup --doctor` correctly identifies all 7 AI CLIs on the dev machine
- Manifest written/read correctly; second `./setup` run = verify-only no-op
- shellcheck + shfmt + secret-scan workflows ready for first PR

## [1.17.0] — 2026-04-25

### Added — Obsidian + markitdown universal tools

**`obsidian` MCP** wired into 6 coding agents (Claude · Codex · Goose · Gemini · Kimi · OpenCode). Claw skipped (no MCP). Backed by `obsidian-mcp` (StevenStavrakis) — filesystem-direct, no Local-REST-API plugin needed. Default vault `~/Desktop/ACTIVITIES`.

**`obsidian-cli`** (Yakitrak / notesmd-cli v0.3.5) installed at `~/.local/bin/obsidian-cli`. Subcommands: `create open print search search-content list daily frontmatter move delete add-vault list-vaults set-default-vault`. Vault `ACTIVITIES` set as default; auto-discovers `Work & IT Things` and lowercase `activities` too.

**`markitdown`** (Microsoft, 0.1.5) installed at `~/.local/bin/markitdown`. Converts PDF / DOCX / XLSX / PPTX / images (OCR) / audio / HTML / JSON / XML / ZIP / CSV → Markdown. Pairs naturally with `/extract` and `obsidian-cli create` for vault ingestion.

### Bundle additions
- `scripts/install-obsidian.sh` — idempotent installer + 6-agent MCP wiring
- `scripts/install-markitdown.sh` — pipx/pip install (with `[all]` extras for full format support)
- `user/docs/MCPS.md` — new sections "Universal MCPs always available" + "Universal CLI tools"

### Per-agent verification
| Agent | Config path | obsidian present |
|---|---|---|
| Claude | `~/.claude.json` | ✅ |
| Codex | `~/.codex/config.toml` | ✅ |
| Goose | `~/.config/goose/mcp.json` | ✅ |
| Gemini | `~/.gemini/settings.json` | ✅ (direct JSON edit — CLI hangs on prompt) |
| Kimi | `~/.kimi/mcp.json` | ✅ |
| OpenCode | `~/.config/opencode/opencode.json` | ✅ |
| Claw | env vars only | N/A |

### Project propagation
markitdown + obsidian are user-scope/system-level — auto-available in every Claude project's session. No per-project install needed. Re-ran `install.sh project` across 22 projects: all idle (bundle template current).

## [1.16.0] — 2026-04-25

### Added — skill-router hook (token-thrifty auto-suggest)

`~/.claude/hooks/skill-router.sh` — `UserPromptSubmit` hook that scans incoming prompts against a curated keyword→skill map and emits a compact "Skill hints" block. The model still uses the `Skill` tool to load any actual skill content; this hook just nudges relevance.

**Token economics**:

| Scenario | Output tokens | Vs. BASE-style always-on injection |
|---|---|---|
| Most prompts (no trigger) | 0 | BASE: ~300 always |
| 1-2 hint match | 25-40 | BASE: ~300 |
| Full 5-hint cap | ~80 worst-case | BASE: ~300 |

Net savings: 70-100% on every prompt vs. BASE-style preamble injection.

**Mechanics**:
1. Hook reads JSON stdin (Claude protocol `.prompt` field)
2. Empty / < 10 char prompts → silent exit
3. Lowercases prompt, walks `~/.claude/hooks/skill-router.conf` line-by-line
4. Each line: `extended-regex|||skill_name|||one-line purpose`
5. Caps at 5 hints per prompt; dedups (same hint set as last prompt → silent)
6. Writes signature to `~/.claude/hooks/.state/skill-router.last` for cross-prompt dedup

**Curated config (~37 triggers)** covering: planning, research, debugging, testing, browser automation, frontend (Next/React/Tailwind), backend (NestJS/Go/Postgres), ops (Railway/Docker/GitHub), git, memory, skill-creation. Stack-aligned with user's Next.js/NestJS/Go/Postgres/Railway profile from `MEMORY.md`.

**Wiring**:
- Live: `~/.claude/settings.json` UserPromptSubmit hooks (alongside CARL — both run, no conflict)
- Bundle: `claude-universal/user/{hooks/skill-router.{sh,conf},settings.json}` so future `install.sh user` deploys it everywhere

### Validated
8/8 smoke tests pass: silent on greetings, single-skill match for narrow intent, multi-hint for broad intent, dedup on repeat prompt.

## [1.15.1] — 2026-04-24

### Project fan-out

Ran `install.sh project <path>` against all 22 Claude-managed projects on the machine. All succeeded (22/22).

Per-project changes (idempotent):
- CLAUDE.md: managed block appended/replaced
- AGENTS.md: symlinked to CLAUDE.md for cross-tool (Codex/Cursor/OpenCode)
- `.claude/settings.json`: deep-merged (backup at `.bak.<timestamp>`)
- `.claude/{agents,commands,hooks}/`: scaffolded with `.gitkeep` + `run-tests-before-commit.sh.example`
- `.gitignore`: bundle entries appended (session/credentials/cache excluded from VCS)

User-scope artifacts (skills, MCPs, plugins) stay at `~/.claude/`; they apply to every project automatically via Claude Code user scope. Updated via `install.sh user`.

Cross-tool re-sync (`sync-cross-tool.sh` + `sync-cross-tool-native.sh`) ran clean — 0 new skills, 0 new commands (all up-to-date from v1.15.0).

### Projects updated
Agytek · Angular/abnormal · bgm-management · BGM_Technologies · bgm-website · Booking-Engine-Jets&Partners · ecommerce-platform · Express · front-end-odontologia · Jet-P-Migration-Project · Jet-Services · jet-services-vault · J-P-Scrapers · LandingPage_CAN · PROGRESS-REVIEW-BGMT-JP · SOLAR_PREDICTION_ML · SOLAR_PREDICTION_ML_ORG · TripVia-International · TS-Vite/streaming-platform · To-Leno/Working_Record_Script · VeluxuryTravel · Working_Record_Script

## [1.15.0] — 2026-04-24

### Added — Browser-act skills fan-out

Three browser-automation skills now force-linked into every coding agent that supports skills (Claude, Codex, Goose, Gemini). Kimi / OpenCode / Claw have no skill concept — skipped.

| Skill | Source | Purpose |
|---|---|---|
| `browser-qa` | `_inspired/everything-claude-code/skills/browser-qa` | Visual QA on deployed features via Playwright/claude-in-chrome |
| `firecrawl-browser` | `~/.agents/skills/firecrawl-browser` | Live page interaction via Firecrawl (scrape + click + form-fill) |
| `playwright-skill` | `_inspired/.../playwright-skill` | Direct Playwright automation (Page/Browser fixtures) |

**Fan-out status (post-sync):**
| Agent | browser-qa | firecrawl-browser | playwright-skill |
|---|---|---|---|
| Claude Code | ✅ | ✅ | ✅ |
| Goose | ✅ | ✅ | ✅ |
| Codex | ✅ (new) | ✅ | ✅ (new) |
| Gemini CLI | ✅ (new) | ✅ (new) | ✅ (new) |
| Kimi / OpenCode / Claw | N/A — skills not supported | | |

### Changed
- **`scripts/sync-cross-tool-native.sh`** — new `sync_browser_skills()` function runs before the Tier-S/A catalog sweep; guarantees browser skills always present regardless of catalog tier drift.
- **`gemini skills link`** calls now auto-confirm via `yes "" | timeout 15` — previously hung on interactive Y/n prompt.

### Pack
- `AI-CODING-AGENTS-PACK.zip` rebuilt to include updated sync script + new codex skill symlinks captured in `configs/codex/skills-list.txt`.
- `AI-CODING-MODELS-PACK.zip` unchanged (model recipes stable).

## [1.14.0] — 2026-04-24

### Added — Four per-model goose launchers
- **`~/.local/bin/gemma4`** — `gemma4:e4b` (9.6 GB). Native Ollama tool_calls, cleanest args.
- **`~/.local/bin/qwen36`** — `qwen3.6:27b` (~16 GB). Disk-gate ≥ 22 GB.
- **`~/.local/bin/llama4`** — `llama4:16x17b` MoE (~67 GB). Disk-gate ≥ 80 GB; suggests `llama3.3:70b` fallback.
- **`~/.local/bin/bonsai`** (rewrite) — now defaults to `bonsai-8b-q4km:latest`. Auto-invokes `reinstall-bonsai` on missing model.
- **`~/.local/bin/reinstall-bonsai`** (rewrite) — pulls `bartowski/prism-ml_Bonsai-8B-unpacked-GGUF` at chosen quant (Q4_K_M default), writes llama3-style Modelfile with tool-call template + `<|eot_id|>` stop tokens. Supports `--quant Q5_K_M|Q6_K|Q8_0`.
- All four launchers share same shape: Ollama health-check → ensure model → export `GOOSE_{PROVIDER,MODEL,OLLAMA_HOST,PLANNER_*}` → `exec goose session`.
- Planner defaults to MiniMax-M2 (aggregator) on all four. Override per launcher via `${PREFIX}_PLANNER_MODEL` env.

### Fixed
- **Bonsai tool-calling broken at Q2 quant** — old `bonsai-8b-q2k` shipped with raw `TEMPLATE {{ .Prompt }}` and no tool slots; `/api/chat` reported `does not support tools`. Swapped to Q4_K_M + custom llama3 chat template.
- **qwen2.5-coder abandoned** — emits tool calls as content JSON (no `<tool_call>` markers), Ollama parser leaves `tool_calls` empty. Removed.
- **gemma3 → gemma4** — gemma3 template omits tool_call extraction; gemma4:e4b has native support.

### Validated (honest results)
| Model | Chat | Native tool_calls | Goose-ready |
|---|---|---|---|
| `gemma4:e4b` | ✅ | ✅ clean args | ✅ |
| `llama3.1:8b` | ✅ | ✅ messy but works | ✅ |
| `bonsai-8b-q4km` | ✅ | ❌ reasoning-only, emits think-tokens to `content` | ⚠️ chat only |
| `qwen3.6:27b` | untested (not pulled, disk-gated) | — | — |
| `llama4:16x17b` | untested (not pulled, disk-gated) | — | — |

**Bonsai finding**: Q4_K_M quant + custom llama3 template did NOT restore tool-calling. Model itself is a reasoning-style generator that outputs long chain-of-thought to `content` instead of emitting `<tool_call>` markers Ollama parses. `bonsai` launcher marked chat-only; use `gemma4` for agent loops.

### Pack (`AI-CODING-AGENTS-PACK.zip`)
- `local-bin/` now bundles all 5 launchers (gemma4, qwen36, llama4, bonsai, reinstall-bonsai) with per-folder `README.md`
- `build-pack.sh` loop extended from 2 → 5 scripts

## [1.13.0] — 2026-04-24

### Added — Ghidra + MCP, BASE, PAUL, CARL, zrok
- **Ghidra 12.0.4** + LaurieWired/GhidraMCP v1.4 via `scripts/install-ghidra.sh`
  - Registers `ghidra` MCP across all 6 AI CLIs
- **BASE** workspace framework (`~/.base/`) — 28 slash commands under `base:*` + base-mcp
- **PAUL** Plan-Apply-Unify Loop — 26 commands under `paul:*`, per-project opt-in
- **CARL** Context Augmentation & Reinforcement Layer — rule injection hook
- **zrok** (`scripts/install-zrok.sh` + `scripts/zrok-share.sh`) replaces ngrok in ZeroClaw tunnel

### Fixed
- Goose config auth broken by prior redaction (placeholder `${VAR}` in YAML sent literally) — restored literal key + chmod 600
- Removed dead `pencil` MCP (AppImage unmount), ngrok binary (31 MB)
- Prune-skills ran: 82 Tier-D skills moved to `~/.claude/skills/_disabled/`

### Pack (`AI-CODING-AGENTS-PACK.zip`)
- Now includes configs for carl/, base/, zeroclaw/ (redacted)
- Ships all new install scripts

## [1.12.0] — 2026-04-24

### Added — deep native per-tool sync + portable pack

**`scripts/sync-cross-tool-native.sh`** — deep port beyond portable subset:
- **Gemini**: `gemini hooks migrate` (first-party Claude→Gemini hook importer) + `gemini skills link` for 60 curated Tier-S/A skills from `SKILLS-CATALOG.md`
- **Codex**: 60 skills symlinked + 13 commands copied + 11 hooks linked into `~/.codex/{skills,commands,hooks}/`
- **OpenCode**: 13 bundled commands ported as native `agent/<name>.md` files + 2 custom providers (MiniMax aggregator via `api.minimaxi.chat`, Ollama cloud)
- **Kimi**: `[providers."minimax-aggregator"]` + `[providers."ollama-cloud"]` + 5 model blocks appended to `~/.kimi/config.toml`

**`scripts/build-pack.sh`** — portable zip of the full agent workstation:
- Output: `~/Desktop/AI-CODING-AGENTS-PACK.zip` (1.2 MB, 784 files)
- Includes: bundle + catalog + inventory + references + per-tool redacted configs + `INSTALL.md`
- Excludes (documented): `_inspired/` (661 MB), whisper venv, lightpanda binary, all API keys
- Redaction: scans settings/config files for `sk-*` / `api_key` / token patterns and replaces with `REDACTED_SET_VIA_ENV` placeholder

### Security
- Goose's `~/.config/goose/config.yaml` had plaintext `GOOSE_OPENAI_API_KEY` — redacted in pack template, live file unchanged (user's call to rotate).
- Pack never contains literal API keys. All configs use env-var references.

### Supported AI coding CLIs (7 total, all on PATH)
| CLI | Version | Native port status |
|---|---|---|
| Claude Code | 2.1.116 | canonical source |
| Kimi CLI | 1.27.0 | providers + models in TOML |
| OpenCode | 1.2.27 | 41 MCP + 13 agents + 2 providers |
| Gemini CLI | 0.38.2 | GEMINI.md + 13 cmds + 60 skills + hooks migrated |
| Goose | 1.31.1 | 358 skills + all hooks (pre-synced) + MCP |
| Codex | 0.63.0 | 73 skills + 13 cmds + 11 hooks |
| Claw Code | 0.1.0 | env-var wiring to aggregator |

## [1.11.0] — 2026-04-21

### Added — cross-tool sync (Claude → Kimi / OpenCode / Gemini)

**`scripts/sync-cross-tool.sh`** — one-shot mirror of Claude Code's portable config to the other three AI CLIs on the machine.

What gets synced:
- **System-prompt managed block** from `~/.claude/CLAUDE.md` →
  - `~/.config/opencode/AGENTS.md` (OpenCode auto-discovers this)
  - `~/.gemini/GEMINI.md` (Gemini CLI auto-discovers this)
  - `~/.kimi/AGENTS.md` (reference only — Kimi may or may not auto-load)
- **MCP server definitions** (stdio-based are cross-tool portable) →
  - OpenCode: merged into `~/.config/opencode/opencode.json` (now 41 servers)
  - Gemini: merged into `~/.gemini/settings.json` (3 servers: lightpanda + fetch + pre-existing pencil)
  - Kimi: registered via `kimi mcp add` (39 servers)
- **Bundled slash commands (13)** → ported to Gemini as TOML files under `~/.gemini/commands/` (OpenCode/Kimi don't expose user-custom slash commands in the same format)

### Gemini CLI installed
- `npm install -g @google/gemini-cli` (v0.38.2) — no sudo required
- Auto-discovers `~/.gemini/GEMINI.md` + `~/.gemini/settings.json` (matches Claude's `~/.claude/CLAUDE.md` + `settings.json` pattern)

### Not portable (documented as explicit caveats)
- **1,488 skills** — Claude's `SKILL.md` format isn't consumed by other tools. Gemini has its own `gemini skills` system with different shape; Kimi/OpenCode don't have skills at all.
- **Hooks** — Claude's `hooks` section in `settings.json` is specific to Claude's lifecycle. OpenCode has its own hook concept; Gemini does too (`gemini hooks`); Kimi doesn't.
- **Plugin-provided MCPs** — live inside `~/.claude/plugins/<marketplace>/<plugin>/` and load on Claude startup; not auto-copied to other tools. Stdio-based MCPs can be registered manually.
- **Permission model** — each tool has its own; not mappable 1-to-1.

### Idempotent re-run
When you add a new command / MCP to the Claude bundle later:
```bash
bash ~/Desktop/ACTIVITIES/claude-universal/scripts/sync-cross-tool.sh
```

## [1.10.0] — 2026-04-21

### Added — claw-code, Warp, Ollama, +2 inspired repos

**Standalone CLI: claw-code** (`scripts/install-claw-code.sh`)
- Clones `ultraworkers/claw-code` (Rust port of Claude Code's agent harness, OSS)
- Builds via cargo (requires rustc ≥ 1.88 — installer auto-detects via system rustup)
- Symlinks `~/.local/bin/claw`
- Writes `~/.config/claw/env.sh` that re-exports `$CLAW_API_KEY` and `$CLAW_API_BASE_URL` as `OPENAI_API_KEY` / `OPENAI_BASE_URL` (claw-code reads OpenAI-compatible env vars natively)
- Writes `~/.config/claw/models.md` cheat-sheet for routing prefixes (`openai/MiniMax-M2`, `openai/glm-5.1`, `ollama/<model>`, etc.)
- Designed for aggregator-style keys (`sk-cp-...`, OpenRouter, packycode, chutes, etc.) — user provides base URL + key via shell env

**Terminal: Warp + Alacritty theme migration** (`scripts/install-warp.sh`)
- Installs `warp-terminal` from the official apt repo (requires sudo for apt-add)
- Parses `~/.config/alacritty/alacritty.toml` and emits `~/.warp/themes/claude-universal.yaml` (colors, normal+bright palettes, font, accent)
- Writes `~/.warp/themes/CLAUDE-UNIVERSAL-README.md` with recommended UI-only settings (opacity, blur, font, keybinds) that Warp doesn't accept from a config file
- Appends managed-block to `~/.zshrc` with shell aliases: `cc`, `kc`, `oc`, `zc`, `cw` (claude/kimi/opencode/zeroclaw/claw) + auto-source of `~/.config/claw/env.sh`

**Cloud LLM gateway: Ollama** (`scripts/install-ollama.sh`)
- Runs the official `https://ollama.com/install.sh` (no sudo required for the binary)
- Writes `~/.config/claw/ollama-cloud.md` with the manual sign-in instructions + cloud-routing recipes (GLM/Qwen/gpt-oss + the built-in `--tool web-search`)
- Wires `OLLAMA_HOST` env var consumption into claw-code via the env.sh file

**+2 inspired repos**
- `arxchibobo/coordinator-orchestrator` → single-root SKILL.md (multi-agent coordinator pattern); surfaced as `~/.claude/skills/coordinator-orchestrator/`
- `WICG/html-in-canvas` → W3C spec repo, NOT a skill; cloned as reference at `~/Desktop/ACTIVITIES/references/html-in-canvas/`

**install-inspired.sh enhancements**
- New `surface_single_skill()` for repos with `SKILL.md` at the root (not under `skills/<name>/`)
- New `install_reference()` for non-skill repos (clones to `references/`, doesn't add to skill discovery)
- New `single-skill` and `reference` kinds in the SOURCES table

### Security note
- The `sk-cp-...` aggregator API key is **never written to any committed file**. All scripts read it from `$CLAW_API_KEY` / `$CLAW_API_BASE_URL` env vars in your shell. Rotate the key if you pasted it anywhere transcript-retained.

### Known
- Claude Code's transcript may still contain the pasted key — rotate if sensitive.
- Warp install requires `sudo` for apt-add — the script asks once and the user enters their password.
- Ollama cloud sign-in (`ollama signin`) is interactive — opens a browser for OAuth.
- The 4 model names you mentioned (`MiniMax-M2.7`, `Music-2.6`, `speech-2.8-hd`, `Hailuo-2.3-Fast`) may not match your aggregator's exact model IDs — check `claw --model openai/<id>` against your provider's model list.

## [1.9.0] — 2026-04-21

### Added — post-install finalization pass

**Cataloged the skill surface.** With 1,487 skill files now visible to Claude Code (296 user-scope + 932 plugin-provided + 259 from inspired repos), discoverability had become a problem. New deliverables:

- **`~/Desktop/ACTIVITIES/skills-inventory.json`** — machine-readable inventory (1,487 entries, frontmatter-parsed)
- **`~/Desktop/ACTIVITIES/SKILLS-CATALOG.md`** — 1,420-line human-readable catalog: tiered (S/A/B/C/D) + categorized (Frontend, Backend, Ops, Marketing, etc.) + stack-fit scored ✅/⚠/❌ against the user's confirmed Next.js+NestJS+Go+Postgres+Railway stack
- **`scripts/scan-skills.sh`** — rebuilds the JSON inventory from disk state (re-runnable)
- **`scripts/generate-skills-catalog.py`** — renders the MD catalog from the JSON with deterministic tier heuristics
- **`scripts/prune-skills.sh`** — safely moves Tier-D skills to `~/.claude/skills/_disabled/<category>/` (fully reversible); supports `--dry-run` and `--category`

The tier heuristics are documented as rules, not vibes: explicit Tier-S skill list, prefix-match for known-good plugins (`railway-`, `impeccable:`, `superpowers:`, etc.), and exact+prefix exclusion for off-stack (Java/Kotlin/Swift/Perl/.NET/Django/Laravel), wrong-domain (healthcare/logistics/energy/DeFi), and framework-self-management (`omc-*`, `ecc-*`, `configure-ecc`).

### Housekeeping
- Removed 13 × `~/.claude/commands/*.universal.md` and 10 × `~/.claude/hooks/*.universal.sh` (bundle-copy siblings the installer creates when the primary file already exists).
- Pruned old `~/.claude/settings.json.bak.*` files, keeping only the 3 most recent.
- `chmod +x ~/.claude/skills/_inspired/base/bin/install.js` (lacked exec bit — doesn't auto-run BASE, just makes it runnable if the user later opts in).

### Why
- 1,487 skills is far beyond useful discoverability — Claude Code loads the lot; overlapping descriptions cause activation ambiguity.
- A deterministic tier heuristic is auditable: every Tier-D placement has a concrete reason ("not in your stack: Java", "content-hash duplicate of X", "self-management for unused framework Y").
- Pruning via `mv` to `_disabled/` (not `unlink`) means any decision is reversible with a single `mv` back — no data loss.

### Still manual (can't be automated)
- `bw login` (interactive)
- `export GEMINI_API_KEY=...` / `OPENAI_API_KEY=...` for langextract + `/extract`
- Claude Code restart (palette refresh)
- Opt-in: `node ~/.claude/skills/_inspired/carl/bin/install.js` (recommended — low cost, keyword-triggered)
- Opt-out: skip BASE (high context cost), BMAD (needs `npm install`), career-ops (unless job-hunting)

## [1.8.0] — 2026-04-20

### Installed — end-to-end

All packages mentioned across this session are now installed and wired to Claude Code:

**CLI tools** (5 installed):
- `langextract` (uvx cache) — structured extraction, needs `GEMINI_API_KEY`/`OPENAI_API_KEY` at call time
- `yt-dlp` (pipx, v2026.3.17) — video/audio downloader
- `whisper` (faster-whisper via dedicated venv at `~/.local/share/claude-universal-whisper/`, wrapped as `~/.local/bin/whisper`) — openai-whisper's CUDA-bloated install (1.5GB for torch+nvidia libs) stalled; replaced with CPU-only faster-whisper (int8 compute, no CUDA). First run downloads ~140MB tiny model from HuggingFace.
- `bw` (npm, v2026.3.0) — Bitwarden/Vaultwarden client. User must `bw login` + `export BW_SESSION="$(bw unlock --raw)"` per shell. Point at Vaultwarden with `bw config server <url>`.
- `lightpanda` (119MB binary at `~/.local/bin/lightpanda`) — registered as Claude MCP via `claude mcp add lightpanda -- ~/.local/bin/lightpanda mcp`.

**Skill repos cloned** (9 of 10 requested — `mistarzewski/agency-agents` returns 404):
- `garrytan/gstack` → 41 skills surfaced
- `Yeachan-Heo/oh-my-claudecode` → 38 skills + CLI commands (autopilot, ralph, ultrawork, team, etc.)
- `affaan-m/everything-claude-code` → 183 skills (tdd-workflow, verification-loop, strategic-compact, continuous-learning, etc.)
- `coreyhaines31/marketingskills` → 36 skills (ad-creative, cold-email, revops, ai-seo, paid-ads, schema-markup, etc.)
- `bmad-code-org/BMAD-METHOD` — cloned, uses npm installer (user runs `npm install -g` to activate)
- `ChristopherKahler/base` / `carl` / `paul` — cloned, use `bin/<name> install` pattern (user opt-in, high context cost)
- `santifer/career-ops` — cloned, npm-based activation

Total: **298 new skills** discoverable by Claude Code.

### Fixed (installer quirks discovered during the install pass)
- `install-lightpanda.sh`: asset suffix was `linux-x86_64` but actual release naming is `x86_64-linux`. Also MCP registration syntax was stale (`serve --mcp` → `mcp` subcommand).
- `install-inspired.sh`: `install_installer_based()` now also checks `bin/<reponame>`, `bin/install.sh`, `bin/setup.sh` for repos that ship installers under `bin/` (Kahler trio convention).
- `install-langextract.sh`: `pipx install` silently skipped langextract (no CLI entry points). Switched verification path to `uvx --from langextract python -c ...`.

### Known limitations
- openai-whisper with default torch pulls 1.5GB of nvidia CUDA libs even on CPU-only machines. Use `faster-whisper` (the wrapper I shipped) instead, OR install openai-whisper against `--index-url https://download.pytorch.org/whl/cpu` if you need openai-whisper's exact CLI compat.
- The Kahler trio (BASE/PAUL/CARL) injects hooks on every UserPromptSubmit — "HIGH context cost" per original inspiration notes. Cloned but not auto-activated. Run `~/.claude/skills/_inspired/<name>/bin/<name> install` to enable.

## [1.7.0] — 2026-04-20

### Fixed — managed-block duplication (silent, months-old bug)
`install_managed_md` used `grep -qF "$begin"` against `<!-- BEGIN: claude-universal managed block -->`, but the actual markers in the bundle templates read `<!-- BEGIN: claude-universal managed block (do not edit between these markers — rerun installer to update) -->`. The grep never matched, so **every install.sh re-run took the append branch**, silently stacking duplicate managed blocks. Live state before the fix: `~/.claude/CLAUDE.md` had 12 copies; every project CLAUDE.md had 4+.

- Both `install.sh` and `install.ps1` now use a **prefix match** (`<!-- BEGIN: claude-universal managed block`) so existing blocks are detected.
- The Python/regex replacement now **collapses all occurrences** into a single trailing block instead of replacing each one (which would have kept N copies if the match had worked).
- One installer re-run collapsed 12 blocks → 1 in `~/.claude/`, and 4 blocks → 1 across all 22 projects.

### Changed — slimmer project template
`project/CLAUDE.md` reduced from 39 lines of 7-section TODO scaffolding to 22 lines with 2 optional sections. Empty TODOs were negative signal: they implied context that wasn't there. The new template says "fill in only if defaults don't fit; delete sections you don't need."

Propagated to all 22 Desktop projects on the install.sh project sweep.

### Fixed — credential leakage in project CLAUDE.md files
Two files carried plaintext credentials in committed markdown:
- `~/Desktop/ecommerce-platform/CLAUDE.md`: PostgreSQL + RabbitMQ passwords, admin seed password
- `~/Desktop/bgm-management/docs/CLAUDE.md`: 4 local-dev user passwords

Both rewritten to point at `bw get password <name>` (via `scripts/vw-helper.sh`) instead of storing the secret. Git history still has them — `git filter-repo` or `git rev-list --all | xargs git grep` recommended if those repos are or will be public.

## [1.6.1] — 2026-04-20

### Fixed (PowerShell hardening pass)
- **Write-Error + exit bug** (5 scripts): with `$ErrorActionPreference = 'Stop'`, `Write-Error` throws a terminating error and pwsh exits with code 1 before the intended `exit N` ever runs. Every `Fail`-path in `install.ps1`, `vw-helper.ps1`, `install-lightpanda.ps1`, `install-langextract.ps1`, `ytdl-to-wiki.ps1` now uses `[Console]::Error.WriteLine + exit N` so the custom exit code actually takes effect.
- **bootstrap-resources parity drift** (18180 vs 18114 rows): .NET regex `\w` is Unicode, Python's is ASCII-only, producing a ~66-row discrepancy. `bootstrap-resources.ps1` now delegates to `python3` when available, giving byte-identical output to the bash twin (both now 18132 lines). Falls back to native pwsh miner only when Python is absent.

### Verified
- Every script pair (`.sh` + `.ps1`) passes syntax check and parity tests on identical inputs.
- `install.ps1` is idempotent: `diff <(jq -S)` against an untouched re-run is empty.
- Error paths now return correct non-zero codes (rc=2 for usage errors, rc=3 for missing deps, etc.).

## [1.6.0] — 2026-04-20

### Added — Cross-platform script twins
Every bundled shell script now has a PowerShell 7+ twin. Same behaviour, idiomatic per shell, fully parity-tested.

- `install.ps1` ↔ `install.sh` — deep JSON merge, managed-block markdown append, hook+command preservation, `.gitignore` merge, `-DryRun` support
- `install-skills.ps1` ↔ `install-skills.sh` — 4 design-skill clone+symlink (falls back to copy on Windows without Developer Mode)
- `scripts/init-llm-wiki.ps1`, `init-improvement-state.ps1`, `bootstrap-resources.ps1` — setup/seed scripts
- `scripts/install-inspired.ps1` — 9 OSS inspiration clones, interactive + `-All` + `-DryRun` flags
- `scripts/install-lightpanda.ps1`, `install-langextract.ps1`, `ytdl-to-wiki.ps1`, `vw-helper.ps1` — helpers

### Fixed
- **Scalar-merge bug** (PowerShell): `$false -eq ''` is true in PowerShell due to loose comparison, which would flip `false` plugin flags to `true`. Fixed with strict type checks.
- **Filename bug**: `[IO.Path]::ChangeExtension($path, $null)` leaves a trailing dot. Replaced with regex strip; `.universal.sh`/`.universal.md` siblings now single-dotted.

### Why
Portability. The bundle is idiomatic shell on Linux/macOS, idiomatic PowerShell on Windows, and works with pwsh 7+ uniformly on all three. No polyglot files, no feature-detection mess.

### Verification
- All 10 `.ps1` files pass `[Parser]::ParseFile` syntax check
- `./install.ps1 -Mode user` produces identical `settings.json` to `./install.sh user` after two rounds of each
- `./install-inspired.ps1 -DryRun` lists all 9 sources and skips each without stdin

## [1.5.0] — 2026-04-20

### Added — "Inspired Bundle Expansion"
Integrated patterns from 20 high-signal Claude Code / AI-agent OSS repos. See `docs/INSPIRATIONS.md` for full credits.

- **12 bundled slash commands** in `user/commands/`:
  - Safety: `/careful`, `/freeze <dir>`, `/unfreeze` (from gstack)
  - Planning: `/autoplan <feature>`, `/pair <q>`, `/compress` (gstack, superpowers)
  - Knowledge: `/learn <insight>`, `/wiki <topic>`, `/retro [N]` (everything-claude-code, karpathy llm-wiki, gstack)
  - Research: `/research <topic>`, `/extract <src>`, `/ytdl <url>` (langextract, yt-dlp)
  - Review: `/crit <target>` (cross-model adversarial review)
- **2 new hooks**:
  - `memory-compiler.sh` (Stop) — deterministic extraction of session activity → `~/Desktop/ACTIVITIES/llm-wiki/YYYY-MM-DD.md`
  - `entity-tracker.sh` (PostToolUse WebFetch|WebSearch) — graphiti-lite JSONL entity log → `entities.jsonl`
- **6 helper scripts** in `scripts/`:
  - `init-llm-wiki.sh` — scaffold the persistent wiki directory
  - `install-inspired.sh` — interactive orchestrator for 9 optional OSS clones
  - `install-lightpanda.sh` — install 16× lighter headless browser + register as MCP
  - `install-langextract.sh` — pip install langextract
  - `ytdl-to-wiki.sh` — yt-dlp → whisper.cpp → markdown pipeline
  - `vw-helper.sh` — safe Bitwarden CLI wrapper (never logs values)
- **3 new docs**: `INSPIRATIONS.md`, `LLM-WIKI.md`, updated `COMMANDS.md`.

### Changed
- `user/settings.json` hooks section — wired `memory-compiler.sh` into Stop, `entity-tracker.sh` into PostToolUse.

### Why
Individual sessions don't compound. The llm-wiki pattern (Karpathy) + `/learn` + `/retro` turns every session into accumulating knowledge. Gstack's safety modes (`/freeze`, `/careful`) prevent destructive surprises. Everything else exists because it's a concrete pattern the user can reuse on command, not a theoretical framework.

### Out of scope (documented, not integrated)
- graphiti (requires Neo4j) → entity-tracker.sh is the lightweight substitute
- BASE/PAUL/CARL (Kahler trio) → clonable via install-inspired.sh, not default
- deep-eye, OpenViking, heretic → noted in INSPIRATIONS.md, deferred

## [1.3.0] — 2026-04-18

### Added
- **Global design skills** — installed to `~/.claude/skills/` so every project on the machine picks them up:
  - `emil-design-eng` (Emil Kowalski animation/UI philosophy, 679 lines)
  - `taste-skill` + variants (`minimalist-skill`, `soft-skill`, `brutalist-skill`, `redesign-skill`) by Leonxlnx
  - `impeccable:*` 20 commands (via `pbakaus/impeccable` plugin, already enabled)
  - `ui-ux-pro-max` (nextlevelbuilder; 50 styles, 21 palettes, 50 font pairings)
- `install-skills.sh` helper script to mirror these on fresh machines.
- `docs/SKILLS.md` updated with the full install matrix + update instructions.

### Why
LLM-generated UI "slop" is a real pain point — generic fonts, boring layouts, AI color palettes. These 4 skills each attack it from a different angle: Emil (motion/polish), Taste (high-agency frontend), Impeccable (anti-pattern enforcement), UI/UX Pro Max (parametric design intelligence). Installed globally means any project can ask "redesign this hero with a brutalist feel" and the right skill auto-loads.

## [1.2.0] — 2026-04-18

### Added
- `user/AGENTS.md` — cross-tool alias (Codex, Cursor, OpenCode, Windsurf read this). Managed-block synced with `CLAUDE.md`.
- `project/AGENTS.md` — symlinked to `CLAUDE.md` on install for the same reason.
- `tool-inventory.sh` hook — detects locally available agents/formatters/runtimes/infra/terminal tools and injects a compact y/n inventory on `SessionStart` so Claude picks real tools first and falls back to web only when needed.
- `docs/WEB-FALLBACK.md` — explicit ladder for what to do when a tool is missing (project MCP → user MCP → CLI → web → ask).

### Changed
- **Slimmed `user/CLAUDE.md` managed block** from ~60 lines to ~20. Moves details to `~/.claude/docs/` (load on demand). Reduces token-tax on every prompt.
- **Slimmed `project/CLAUDE.md`** — now a lean template that points at user-level for universals; project file holds only overrides and project-specific context.
- `session-context.sh` now delegates to `tool-inventory.sh` (falls back to minimal git-only output if inventory hook missing).

### Why
LLMs were being overwhelmed by long `CLAUDE.md` files duplicated across projects. New design: **short always-on core + on-demand docs + runtime tool detection**. Bundle stays universal but never crowds the context window.

## [1.1.0] — 2026-04-18

### Added
- Merge-safe `install.sh` — never overwrites existing configs; JSON deep-merges `settings.json`, appends to `CLAUDE.md` with managed-block markers, preserves user's hooks.
- `docs/` suite: `CHANGELOG.md`, `RULES.md`, `SETTINGS.md`, `DEPLOYMENT.md`, `HOOKS.md`, `MCPS.md`, `SKILLS.md`, `ACPS.md`, `PLUGINS.md`, `AGENTS.md`, `COMMANDS.md`.
- Karpathy-inspired behavioral rules baked into `user/CLAUDE.md` inside a managed block.

### Changed
- `install.sh` now wraps every file write in `backup → merge → verify`.
- `user/CLAUDE.md` wrapped in `<!-- BEGIN/END: claude-universal managed block -->` markers.

## [1.0.0] — 2026-04-18

### Added
- Initial `user/` scope: curated `settings.json` (80 allows / 19 denies / 25 asks), preferences `CLAUDE.md`, `.gitignore` template.
- Initial `project/` scope: project `CLAUDE.md` template with TODOs, scoped `settings.json`, empty `agents/` and `commands/` stubs.
- 5 lifecycle hooks: `block-ai-attribution`, `block-secret-writes`, `auto-format`, `notify-stop`, `session-context`.
- Example project hook: `run-tests-before-commit.sh.example`.
- `install.sh` with `--dry-run`, `user`, and `project <path>` modes.

### Security
- Removed `skipDangerousModePermissionPrompt` (silent-approval off).
- Hard-denied `rm -rf /`, `sudo rm`, `mkfs*`, `dd`, `curl | bash`, fork bombs.
- Routed destructive commands (`docker*`, `git push`, `git reset --hard`, `npm publish`, `kubectl delete`, `terraform apply/destroy`, `railway up`, `vercel deploy`) through `ask` tier.

---

_Maintenance rule:_ when a bundle file changes materially, add an entry here under an `## [Unreleased]` section, then cut a numbered release when you redeploy with `install.sh user`.

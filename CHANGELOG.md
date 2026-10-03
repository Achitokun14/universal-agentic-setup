# Changelog

The full version history lives at [user/docs/CHANGELOG.md](user/docs/CHANGELOG.md). The latest 3 versions are mirrored below.

For all versions: see [user/docs/CHANGELOG.md](user/docs/CHANGELOG.md).

## [2.0.0] — 2026-10-03

**Renamed `claude-universal` → `universal-agentic-setup`.** One agent-neutral source
of truth rendered into 26 agents. Full upgrade path: [MIGRATION.md](MIGRATION.md).

### BREAKING
- Managed-block markers renamed: `<!-- BEGIN: universal-agentic-setup … -->`.
  **Uninstall v1 before applying v2** — old `claude-universal` blocks are not replaced in place.
- Manifest moved to `~/.universal-agentic-manifest.json` (v1 file is detected + reported).
- `scripts/sync-cross-tool.sh` + `sync-cross-tool-native.sh` **removed**, superseded by
  `scripts/agentic_sync.py` (portable subset fully covered; machine-bound deep-sync dropped).
- `user/AGENTS.md` removed — superseded by `core/AGENTS.md`.
- `setup` is now a real script (the v1 git symlink checked out 0-byte on Windows).

### Added — agent-neutral core + 26-agent engine
- `core/AGENTS.md` (universal rules), `core/mcp/servers.json` (12-server catalog,
  6 default-enabled, env var names only), `core/skills/catalog.json`
  (21 core / 14 optional / 9 rejected), `core/tools/catalog.json` (8+7 tools)
- `agents/registry.json` — one entry per verified agent: detect hints, per-OS
  user-scope paths, MCP format id, manual flag, source URL. 18 automatable,
  8 manual (YAML configs, GUI-managed MCP, cloud-only)
- `scripts/agentic_sync.py` (stdlib-only, py3.9+): `--dry-run` default / `--apply` /
  `--only` / `--skip` / `--list [--markdown]` / `--doctor` / `--uninstall` / `--skills`.
  Native MCP renders: Claude `~/.claude.json`, Codex TOML, Gemini/Qwen settings.json,
  mcp.json-style (Cursor/Copilot/Junie/Factory/Kimi Code/omp/Cline/Amazon-Q),
  OpenCode `mcp` local|remote, Zed `context_servers`, Amp `amp.mcpServers`,
  Crush `mcp`, Antigravity/Windsurf `serverUrl`. Preserves unrelated keys and user
  entries; timestamped `.bak` before any change; apply is byte-identical idempotent;
  uninstall restores backups byte-original.
- `setup.ps1` (PS 5.1-compatible; `install.ps1`/`setup.ps1` now UTF-8 BOM — fixes a
  pre-existing PS 5.1 parse failure on BOM-less files with non-ASCII)
- `docs/AGENTS-MATRIX.md` (generated), `docs/SKILLS.md`, `docs/TOOLS.md`, `MIGRATION.md`
- `tests/test_agentic_sync.py` — 32 unittest cases (golden renders per format,
  idempotency, managed-block insert/remove, unrelated-keys preservation, uninstall
  restore, registry schema, no-secret-values)

### Changed
- `setup.sh` phase 4 wires every detected agent via `agentic_sync.py`; phase 6 writes
  the v2 manifest (merge-mode, agents section preserved); `--uninstall` unwinds both layers
- `install.sh` / `install.ps1` user mode: `~/.claude/AGENTS.md` block sourced from
  `core/AGENTS.md`, then `agentic_sync.py --apply --only claude-code` (MCP catalog merge)
- `tests/smoke.sh` extended to 23 assertions; CI adds `windows-latest`
  (python tests + `setup.ps1 -DryRun`) and unittest steps on ubuntu/macos
- README rewritten with computed numbers (10 registered hooks — v1 table listed 11
  incl. an unshipped `carl-hook.py`; 13 commands incl. `/unfreeze`, dropping
  nonexistent `/plan`; permissions 85/19/22 — was 80/19/25; MCP/skill catalogs
  instead of author-machine counts)

## [1.18.0] — 2026-04-26

### Added — one-command universal `./setup`

`./setup` is now the canonical entrypoint. Detects OS, pkg-manager, shell, and which AI CLIs are installed, then plans → confirms → installs → verifies. Idempotent (re-run = safe no-op when up-to-date), updateable (`--update`), reversible (`--uninstall`).

**New flags:**
`--dry-run` · `--yes` · `--update` · `--uninstall` · `--doctor` · `--with=NAME[,NAME]` · `--skip=STEP[,STEP]` · `--only=user` · `--version` · `--help`

**Architecture:**
- `setup.sh` (orchestrator, ~280 lines)
- `lib/{ui,detect,deps,plan,apply,verify}.sh` (single-purpose helpers)
- `VERSION` file as single source-of-truth
- Manifest at `~/.claude/.claude-universal-manifest.json` records install state for clean updates/uninstalls

### CI + tests
- `.github/workflows/lint.yml` — shellcheck, shfmt (advisory), secret-scan, path-leak-scan
- `.github/workflows/smoke.yml` — runs `./setup --version|--help|--doctor|--dry-run --yes` + `tests/smoke.sh` on Ubuntu + macOS
- `tests/smoke.sh` — 15-assertion smoke suite (15/15 passing)

### Fixed
- `notify-stop.sh` — cross-OS now (Linux notify-send / macOS osascript / Windows PowerShell), silently no-op if no notifier
- `skill-router.sh` — falls back to script-adjacent `skill-router.conf` if `~/.claude/hooks/skill-router.conf` is absent (lets fresh installs and tests work)
- Removed misleading TODO in `install-inspired.sh:183` (skills-selective falls through correctly to surface_skills)

### Cleanups
- `.shellcheckrc` + `.editorconfig` for consistent contributor formatting
- `install.sh` reads `VERSION` and supports `--version` + `--help`


## [1.17.0] — 2026-04-25

### Added — Obsidian + markitdown universal tools
- `obsidian` MCP wired into 6 coding agents (Claude · Codex · Goose · Gemini · Kimi · OpenCode), backed by `obsidian-mcp` (StevenStavrakis), default vault `~/Desktop/ACTIVITIES`
- `obsidian-cli` (Yakitrak/notesmd-cli v0.3.5) at `~/.local/bin/obsidian-cli`
- `markitdown` (Microsoft 0.1.5) at `~/.local/bin/markitdown` — PDF/DOCX/XLSX/PPTX/images/audio/HTML → MD
- `scripts/install-obsidian.sh`, `scripts/install-markitdown.sh`
- `user/docs/MCPS.md` — new "Universal MCPs always available" + "Universal CLI tools" sections

## [1.16.0] — 2026-04-25

### Added — skill-router hook (token-thrifty auto-suggest)
- `~/.claude/hooks/skill-router.sh` — UserPromptSubmit hook scanning prompts against curated keyword→skill map
- 0 tokens when no trigger fires; ≤80 tokens cap when triggers match (vs ~300 always-on for BASE-style)
- 37 curated triggers covering planning · research · debug · TDD · browser · frontend · backend · ops · git · memory
- Editable `skill-router.conf`, reloaded each prompt
- Dedup via sha1 of last hint set — repeat prompts emit nothing

## [1.15.1] — 2026-04-24

### Project fan-out
- Ran `install.sh project <path>` against all 22 Claude-managed projects on the host machine
- Per-project: managed CLAUDE.md block, settings.json deep-merge, AGENTS.md symlink, hook examples, .gitignore append
- User-scope artifacts (skills, MCPs, plugins) stay at `~/.claude/`; auto-apply to every project

---

For releases prior to 1.15.1, see [user/docs/CHANGELOG.md](user/docs/CHANGELOG.md).

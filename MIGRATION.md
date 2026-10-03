# Migration: claude-universal (v1) → universal-agentic-setup (v2)

v2 keeps the Claude-canonical layer (`user/`, `install.sh`, hooks, commands) and
adds an agent-neutral core (`core/`, `agents/`, `scripts/agentic_sync.py`) that
wires **26 agents** instead of 7. This file is the honest upgrade path.

## What changed

| v1 (`claude-universal` ≤ 1.18.0) | v2 (`universal-agentic-setup` 2.0.0) |
|---|---|
| 7 CLIs, Claude-Code-canonical sync | 26 agents from a verified registry; agent-neutral `core/` |
| `scripts/sync-cross-tool.sh` + `sync-cross-tool-native.sh` | `scripts/agentic_sync.py` (dry-run default, idempotent, reversible) |
| Managed-block markers `<!-- BEGIN: claude-universal … -->` | `<!-- BEGIN: universal-agentic-setup … -->` |
| Manifest `~/.claude/.claude-universal-manifest.json` | `~/.universal-agentic-manifest.json` (agents + backups + version) |
| `setup` = git symlink to `setup.sh` (0-byte on Windows checkouts) | `setup` = real script; new `setup.ps1` for PowerShell |
| MCPs: prose docs + author-machine wiring | `core/mcp/servers.json` catalog; merge into each agent's native format |
| Skills: third-party design-family installer only | `core/skills/catalog.json` tiers + `--skills` via `npx skills add … -g -y` |
| CI: ubuntu + macOS | + `windows-latest` (python tests + `setup.ps1 -DryRun`) |

## BREAKING changes

1. **Managed-block markers renamed.** v2 installers no longer recognize
   `<!-- BEGIN: claude-universal … -->` blocks — running v2 over a v1 deployment
   would append a *second* block. Uninstall v1 first (below).
2. **Manifest moved** from `~/.claude/.claude-universal-manifest.json` to
   `~/.universal-agentic-manifest.json`. v2 detects the old file and tells you.
3. **`sync-cross-tool*.sh` removed.** Their portable subset (context block +
   MCP entries + skills) is fully covered by `agentic_sync.py`. Their
   machine-bound parts (mirroring hooks/commands into `~/.codex`,
   OpenCode command→agent porting, Kimi/MiniMax provider TOML) are **not**
   carried over — they hardcoded the original author's home layout.
4. **`user/AGENTS.md` removed** — superseded by `core/AGENTS.md` (the single
   agent-neutral rules source; installers and the sync engine now share it).
5. **`./setup` is a regular file** (was a symlink; checked out empty on Windows).

## Upgrade steps

```bash
# 1. Remove the v1 deployment (run from your v1.18.0 checkout):
cd claude-universal && ./setup --uninstall
#    (restores settings.json backups, strips v1 managed blocks,
#     removes v1 hooks/docs, deletes the v1 manifest)

# 2. Get v2 and deploy:
git clone https://github.com/Achitokun14/universal-agentic-setup.git
cd universal-agentic-setup
./setup                 # or: .\setup.ps1 on Windows
```

If you skipped step 1: `agentic_sync.py --doctor` and `./setup` will both warn
about the leftover v1 manifest. To clean just the stale v1 blocks by hand:

```bash
for f in ~/.claude/CLAUDE.md ~/.claude/AGENTS.md; do
  [ -f "$f" ] && sed -i '/<!-- BEGIN: claude-universal/,/<!-- END: claude-universal/d' "$f"
done
rm -f ~/.claude/.claude-universal-manifest.json
```

## Downgrade / uninstall v2

```bash
python3 scripts/agentic_sync.py --uninstall --apply   # every agent it wired
./setup --uninstall                                    # Claude layer + manifest
```

Uninstall restores the newest timestamped `.bak` for every file it touched and
removes files it created from scratch; state is tracked in the v2 manifest.

## For contributors

- `VERSION` ↔ `CHANGELOG.md` + `user/docs/CHANGELOG.md` must stay in sync (CI enforces).
- `docs/AGENTS-MATRIX.md` is generated: `python scripts/agentic_sync.py --list --markdown > docs/AGENTS-MATRIX.md`.
- Tests: `python -m unittest discover -s tests` and `bash tests/smoke.sh`
  (both sandbox-safe — they never touch your real home).

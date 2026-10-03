#!/usr/bin/env bash
# setup.sh — single entrypoint for universal-agentic-setup.
# One command installs, configures, and updates the entire workstation.
#
#   ./setup                      # install (or no-op if up-to-date)
#   ./setup --update             # git pull + reapply
#   ./setup --dry-run            # show plan, change nothing
#   ./setup --yes                # no prompts
#   ./setup --with=obsidian,markitdown
#   ./setup --skip=skills,sync
#   ./setup --only=user
#   ./setup --uninstall          # restore .bak files, remove bundle entries
#   ./setup --doctor             # diagnose only
#   ./setup --version
#   ./setup --help

set -euo pipefail

BUNDLE_DIR="$(cd "$(dirname "$0")" && pwd)"
VERSION="$(cat "$BUNDLE_DIR/VERSION" 2>/dev/null || echo dev)"

# Defaults
SETUP_DRY=0
SETUP_YES=0
SETUP_UPDATE=0
SETUP_UNINSTALL=0
SETUP_DOCTOR=0
SETUP_WITH=""
SETUP_SKIP=""
SETUP_ONLY=""
export SETUP_DRY SETUP_YES SETUP_UPDATE SETUP_UNINSTALL SETUP_DOCTOR SETUP_WITH SETUP_SKIP SETUP_ONLY

# shellcheck source=lib/ui.sh
. "$BUNDLE_DIR/lib/ui.sh"
# shellcheck source=lib/detect.sh
. "$BUNDLE_DIR/lib/detect.sh"
# shellcheck source=lib/deps.sh
. "$BUNDLE_DIR/lib/deps.sh"
# shellcheck source=lib/plan.sh
. "$BUNDLE_DIR/lib/plan.sh"
# shellcheck source=lib/apply.sh
. "$BUNDLE_DIR/lib/apply.sh"
# shellcheck source=lib/verify.sh
. "$BUNDLE_DIR/lib/verify.sh"

usage() {
  cat <<USAGE
universal-agentic-setup v$VERSION — one-command installer/updater

Usage:
  ./setup                       Install (or no-op if up-to-date)
  ./setup --update              git pull + reapply
  ./setup --dry-run             Show plan, no changes
  ./setup --yes                 No prompts (auto-yes)
  ./setup --with=NAME[,NAME]    Install opt-in add-ons
                                  (e.g. obsidian, markitdown, lightpanda,
                                   ghidra, langextract, ollama, claw-code,
                                   warp, zrok, inspired)
  ./setup --skip=STEP[,STEP]    Skip steps (skills, scaffolding, sync)
  ./setup --only=user           Only apply user-scope, skip everything else
  ./setup --uninstall           Restore .bak files, remove bundle entries
  ./setup --doctor              Diagnose without changing anything
  ./setup --version             Print version and exit
  ./setup --help                Show this help

Examples:
  ./setup                                       # first install
  ./setup --dry-run                             # preview
  ./setup --yes --with=obsidian,markitdown      # full + 2 add-ons, no prompts
  ./setup --update                              # later: git pull + reapply
  ./setup --doctor                              # what's missing on my machine?
USAGE
}

# Arg parsing
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)    SETUP_DRY=1; shift ;;
    --yes|-y)     SETUP_YES=1; shift ;;
    --update)     SETUP_UPDATE=1; shift ;;
    --uninstall)  SETUP_UNINSTALL=1; shift ;;
    --doctor)     SETUP_DOCTOR=1; shift ;;
    --with=*)     SETUP_WITH="${1#--with=}"; shift ;;
    --skip=*)     SETUP_SKIP="${1#--skip=}"; shift ;;
    --only=*)     SETUP_ONLY="${1#--only=}"; shift ;;
    --version)    echo "universal-agentic-setup $VERSION"; exit 0 ;;
    -h|--help)    usage; exit 0 ;;
    *) err "unknown flag: $1"; usage; exit 1 ;;
  esac
done

# Re-export after parsing
export SETUP_DRY SETUP_YES SETUP_WITH SETUP_SKIP SETUP_ONLY

# ─── doctor mode (read-only) ──────────────────────────────────────
if [[ "$SETUP_DOCTOR" -eq 1 ]]; then
  step "universal-agentic-setup doctor (v$VERSION)"
  detect_all
  plan_print
  verify_doctor
  exit 0
fi

# ─── uninstall mode ───────────────────────────────────────────────
if [[ "$SETUP_UNINSTALL" -eq 1 ]]; then
  step "universal-agentic-setup — uninstall"
  manifest="$HOME/.universal-agentic-manifest.json"
  legacy_manifest="$HOME/.claude/.claude-universal-manifest.json"
  if [[ ! -f "$manifest" && ! -f "$legacy_manifest" ]]; then
    err "no manifest at $manifest (or v1 $legacy_manifest) — nothing to uninstall"
    exit 1
  fi
  warn "this will:"
  warn "  • restore the most recent ~/.claude/settings.json.bak.* (if any)"
  warn "  • remove managed blocks (CLAUDE.md, AGENTS.md) and managed MCP entries"
  warn "  • run agentic_sync.py --uninstall across every agent it wired"
  warn "  • delete bundle-owned files (docs, bundled commands, hooks)"
  warn "  • leave your custom files alone"
  if ! confirm "proceed?"; then
    say "cancelled"
    exit 0
  fi

  # Restore latest backup
  latest_bak="$(ls -t "$HOME"/.claude/settings.json.bak.* 2>/dev/null | head -1 || true)"
  if [[ -n "$latest_bak" ]]; then
    run "cp '$latest_bak' '$HOME/.claude/settings.json'"
    ok "restored settings from $latest_bak"
  fi

  # Strip managed block from CLAUDE.md
  if [[ -f "$HOME/.claude/CLAUDE.md" ]]; then
    if [[ "$SETUP_DRY" -eq 1 ]]; then
      hint "(dry-run) sed delete managed block"
    else
      sed -i.unrolled '/<!-- BEGIN: universal-agentic-setup managed block/,/<!-- END: universal-agentic-setup managed block/d' \
        "$HOME/.claude/CLAUDE.md" 2>/dev/null || true
      sed -i.unrolled '/<!-- BEGIN: universal-agentic-setup managed block/,/<!-- END: universal-agentic-setup managed block/d' \
        "$HOME/.claude/AGENTS.md" 2>/dev/null || true
      ok "stripped managed blocks from CLAUDE.md and AGENTS.md"
    fi
  fi

  # v2: unwind every agent agentic_sync.py wired (restores .bak backups)
  if command -v python3 >/dev/null 2>&1 && [[ -f "$manifest" ]]; then
    if [[ "$SETUP_DRY" -eq 1 ]]; then
      hint "(dry-run) python3 scripts/agentic_sync.py --uninstall --apply"
    else
      python3 "$BUNDLE_DIR/scripts/agentic_sync.py" --uninstall --apply 2>&1 | tail -10 || true
    fi
  fi

  # Remove bundle-owned hooks
  for h in auto-format block-ai-attribution block-secret-writes entity-tracker memory-compiler \
           notify-stop session-context skill-router tool-inventory track-improvement track-resources; do
    run "rm -f '$HOME/.claude/hooks/${h}.sh' '$HOME/.claude/hooks/${h}.conf'"
  done

  # Remove docs/ (bundle-owned)
  run "rm -rf '$HOME/.claude/docs'"

  # Remove manifests (v2 + legacy v1 if present)
  run "rm -f '$manifest'"
  run "rm -f '$legacy_manifest'"
  ok "uninstall complete"
  exit 0
fi

# ─── update mode ──────────────────────────────────────────────────
if [[ "$SETUP_UPDATE" -eq 1 ]]; then
  step "universal-agentic-setup — update (v$VERSION)"
  cd "$BUNDLE_DIR"
  if [[ -d .git ]]; then
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
      err "local changes in $BUNDLE_DIR — commit or stash first"
      exit 1
    fi
    say "git pull --ff-only"
    run "git pull --ff-only" || die "git pull failed"
    # Re-read VERSION (it may have changed)
    VERSION="$(cat "$BUNDLE_DIR/VERSION" 2>/dev/null || echo dev)"
  else
    warn "not a git checkout — skipping git pull (call git manually)"
  fi
fi

# ─── default = install/no-op ─────────────────────────────────────
step "universal-agentic-setup v$VERSION — setup"
detect_all
plan_print

if [[ "$BUNDLE_STATE" = installed && "$INSTALLED_VERSION" = "$VERSION" && "$SETUP_UPDATE" -eq 0 ]]; then
  say "already up-to-date — running verify only"
  verify_all
  exit 0
fi

if [[ "$SETUP_DRY" -eq 0 ]] && ! confirm "proceed with the plan above?"; then
  say "cancelled"
  exit 0
fi

deps_install_missing
apply_all
verify_all

step "8/8 — done"
ok "universal-agentic-setup v$VERSION installed"
hint "Next: start a new session in your AI CLI to load merged settings."
hint "Re-run later: ./setup            # idempotent no-op if up-to-date"
hint "             ./setup --update    # pull latest from upstream"
hint "             ./setup --doctor    # verify everything's wired"

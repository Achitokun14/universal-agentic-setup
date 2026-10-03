#!/usr/bin/env bash
# universal-agentic-setup — Claude-canonical installer — MERGE mode.
# Never overwrites existing configs: deep-merges JSON, appends managed blocks to markdown.
#
# Modes:
#   install.sh [--dry-run] user                 # install/upgrade user scope
#   install.sh [--dry-run] project /path/to/repo # install/upgrade project scope

set -euo pipefail

BUNDLE_DIR="$(cd "$(dirname "$0")" && pwd)"
VERSION="$(cat "$BUNDLE_DIR/VERSION" 2>/dev/null || echo 'dev')"
DRY_RUN=0
MODE=""
TARGET=""

# ---- arg parsing ----
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    --version) echo "universal-agentic-setup $VERSION"; exit 0 ;;
    -h|--help) MODE="help"; shift ;;
    user|project) MODE="$1"; shift ;;
    *) TARGET="$1"; shift ;;
  esac
done

say() { echo "▸ $*"; }
warn() { echo "⚠ $*" >&2; }

do_run() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "   (dry-run) $*"
  else
    eval "$*"
  fi
}

backup_if_exists() {
  local path="$1"
  if [[ -e "$path" && ! -L "$path" ]]; then
    local bak="${path}.bak.$(date +%Y%m%d_%H%M%S)"
    say "backup: $path → $bak"
    do_run "cp -a '$path' '$bak'"
  fi
}

# ---- dependency check ----
need() {
  if ! command -v "$1" >/dev/null 2>&1; then
    warn "missing dependency: $1"
    return 1
  fi
}
need python3 || { echo "error: python3 required for JSON merge"; exit 1; }
need jq || warn "jq not installed — hooks need it. Install: sudo apt install jq"

# ---- JSON deep-merge helper (writes merged JSON to stdout) ----
merge_json() {
  # usage: merge_json <existing-file-or-/dev/null> <bundle-file>
  local existing="$1"; local bundle="$2"
  python3 - "$existing" "$bundle" <<'PY'
import json, os, sys

def load(p):
    if not p or not os.path.exists(p) or os.path.getsize(p) == 0:
        return {}
    try:
        return json.load(open(p))
    except json.JSONDecodeError as e:
        sys.stderr.write(f"⚠ JSON decode error in {p}: {e}\n")
        sys.exit(2)

def dedupe_list(a, b):
    # preserve order; dedupe by stringified value
    seen = set(); out = []
    for item in a + b:
        key = json.dumps(item, sort_keys=True)
        if key not in seen:
            seen.add(key); out.append(item)
    return out

def merge(a, b):
    """Deep-merge b into a. Arrays are concatenated + deduped.
       Objects are merged key-by-key. Scalars: b wins for missing, a kept otherwise."""
    if isinstance(a, dict) and isinstance(b, dict):
        out = dict(a)
        for k, v in b.items():
            out[k] = merge(a[k], v) if k in a else v
        return out
    if isinstance(a, list) and isinstance(b, list):
        return dedupe_list(a, b)
    # scalar conflict: prefer existing (a), so reruns never clobber user tweaks
    return a if a not in (None, "", []) else b

def normalize_hooks(hooks_section):
    """Collapse duplicate hook entries by (event, matcher).
       Two Stop entries like [{hooks:[a,b]}, {hooks:[b,c]}] → [{hooks:[a,b,c]}]."""
    if not isinstance(hooks_section, dict):
        return hooks_section
    out = {}
    for event, entries in hooks_section.items():
        if not isinstance(entries, list):
            out[event] = entries
            continue
        # group by matcher (or "" for unmatched events like Stop)
        by_matcher = {}
        for entry in entries:
            if not isinstance(entry, dict):
                continue
            m = entry.get("matcher", "")
            slot = by_matcher.setdefault(m, {"matcher": m, "hooks": []} if m else {"hooks": []})
            seen = {json.dumps(h, sort_keys=True) for h in slot["hooks"]}
            for h in entry.get("hooks", []):
                k = json.dumps(h, sort_keys=True)
                if k not in seen:
                    seen.add(k); slot["hooks"].append(h)
        out[event] = [v for v in by_matcher.values()]
    return out

existing = load(sys.argv[1])
bundle = load(sys.argv[2])
merged = merge(existing, bundle)
if isinstance(merged.get("hooks"), dict):
    merged["hooks"] = normalize_hooks(merged["hooks"])
print(json.dumps(merged, indent=2, ensure_ascii=False))
PY
}

# ---- managed-block append/replace for markdown ----
install_managed_md() {
  # usage: install_managed_md <target-md> <bundle-md>
  local target="$1"; local bundle="$2"
  local tmp; tmp="$(mktemp)"
  # Use PREFIX-only check: actual markers in the bundle template include a
  # trailing comment ("(do not edit between these markers — rerun installer to update)")
  # so we match a stable prefix, not the exact string.
  local begin_prefix='<!-- BEGIN: universal-agentic-setup managed block'

  if [[ -f "$target" ]] && grep -qF "$begin_prefix" "$target"; then
    # Replace/collapse existing managed block(s)
    say "markdown: replacing managed block(s) in $target"
    python3 - "$target" "$bundle" > "$tmp" <<'PY'
import sys, re
tgt, bdl = open(sys.argv[1]).read(), open(sys.argv[2]).read()
# Match any "BEGIN: universal-agentic-setup managed block..." through "END: universal-agentic-setup managed block -->"
# plus surrounding blank lines. Collapse ALL occurrences (historical duplicates) into a SINGLE
# trailing block.
pat = re.compile(
    r"\n*<!-- BEGIN: universal-agentic-setup managed block.*?<!-- END: universal-agentic-setup managed block -->\n*",
    re.DOTALL,
)
cleaned = pat.sub('', tgt).rstrip()
sys.stdout.write((cleaned + '\n\n' if cleaned else '') + bdl.strip() + '\n')
PY
    do_run "mv '$tmp' '$target'"
  elif [[ -f "$target" ]]; then
    # Append managed block without touching user content
    say "markdown: appending managed block to $target"
    do_run "cp '$target' '$tmp'"
    do_run "printf '\n\n' >> '$tmp'"
    do_run "cat '$bundle' >> '$tmp'"
    do_run "mv '$tmp' '$target'"
  else
    say "markdown: creating $target from bundle"
    do_run "cp '$bundle' '$target'"
  fi
}

# ---- gitignore merge (only append missing lines) ----
merge_gitignore() {
  local target="$1"; local bundle="$2"
  local added=0
  while IFS= read -r line; do
    [[ -z "$line" || "$line" =~ ^# ]] && continue
    if ! grep -qxF "$line" "$target" 2>/dev/null; then
      if [[ "$added" -eq 0 ]]; then
        do_run "printf '\n# universal-agentic-setup\n' >> '$target'"
        added=1
      fi
      do_run "echo '$line' >> '$target'"
    fi
  done < "$bundle"
  if [[ "$added" -eq 1 ]]; then say "gitignore: appended missing entries"; fi
  return 0
}

usage() {
  cat <<USAGE
universal-agentic-setup installer (v$VERSION)

Usage:
  $0 [--dry-run] user
  $0 [--dry-run] project /absolute/path/to/repo
  $0 --version
  $0 --help

Modes:
  user     Merge into ~/.claude/ (global scope)
  project  Merge into <path>/ (project scope)

Merge rules:
  - settings.json    : deep JSON merge, array dedupe, existing scalars preserved
  - CLAUDE.md        : managed-block replace-or-append (never overwrites your content)
  - hooks/*.sh       : added only if absent; existing hooks keep their version
  - docs/*.md        : always refreshed (bundle-owned)
  - .gitignore       : append missing entries only

Examples:
  $0 --dry-run user
  $0 user
  $0 project ~/Desktop/my-repo
USAGE
}

[[ "$MODE" == "help" ]] && { usage; exit 0; }
[[ -z "$MODE" ]] && { usage; exit 1; }

# ======================================================
# USER SCOPE
# ======================================================
if [[ "$MODE" == "user" ]]; then
  CLAUDE_DIR="$HOME/.claude"
  say "User scope → $CLAUDE_DIR/"
  do_run "mkdir -p '$CLAUDE_DIR' '$CLAUDE_DIR/hooks' '$CLAUDE_DIR/docs'"

  # settings.json — deep merge
  target="$CLAUDE_DIR/settings.json"
  backup_if_exists "$target"
  merged="$(merge_json "${target:-/dev/null}" "$BUNDLE_DIR/user/settings.json")"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    say "settings.json: would merge (preview first 30 lines):"
    echo "$merged" | head -30 | sed 's/^/     /'
  else
    echo "$merged" > "$target"
    say "settings.json: merged → $target"
  fi

  # CLAUDE.md — managed block
  install_managed_md "$CLAUDE_DIR/CLAUDE.md" "$BUNDLE_DIR/user/CLAUDE.md"

  # AGENTS.md — managed block from the agent-neutral core (read by Claude Code,
  # Codex, Cursor, OpenCode, Windsurf, ...; same source agentic_sync.py uses)
  install_managed_md "$CLAUDE_DIR/AGENTS.md" "$BUNDLE_DIR/core/AGENTS.md"

  # Hooks — only add if missing; skip .universal side-copy if bundle == existing (byte-identical)
  for h in "$BUNDLE_DIR"/user/hooks/*.sh; do
    [[ -f "$h" ]] || continue
    name="$(basename "$h")"
    dst="$CLAUDE_DIR/hooks/$name"
    if [[ -f "$dst" ]]; then
      if cmp -s "$h" "$dst"; then
        : # identical — no action, no .universal copy needed
      else
        alt="${dst%.sh}.universal.sh"
        say "hook: $name differs — bundle version saved to $(basename "$alt")"
        do_run "cp '$h' '$alt'"
        do_run "chmod +x '$alt'"
      fi
    else
      do_run "cp '$h' '$dst'"
      do_run "chmod +x '$dst'"
      say "hook: installed $name"
    fi
  done

  # Docs — bundle-owned, always refresh
  for d in "$BUNDLE_DIR"/user/docs/*.md; do
    [[ -f "$d" ]] || continue
    name="$(basename "$d")"
    do_run "cp '$d' '$CLAUDE_DIR/docs/$name'"
  done
  say "docs: refreshed $CLAUDE_DIR/docs/"

  # Commands — only add if missing; skip .universal side-copy if byte-identical
  do_run "mkdir -p '$CLAUDE_DIR/commands'"
  if [[ -d "$BUNDLE_DIR/user/commands" ]]; then
    for c in "$BUNDLE_DIR"/user/commands/*.md; do
      [[ -f "$c" ]] || continue
      name="$(basename "$c")"
      dst="$CLAUDE_DIR/commands/$name"
      if [[ -f "$dst" ]]; then
        if cmp -s "$c" "$dst"; then
          : # identical — no .universal copy needed
        else
          alt="${dst%.md}.universal.md"
          say "command: $name differs — bundle version saved to $(basename "$alt")"
          do_run "cp '$c' '$alt'"
        fi
      else
        do_run "cp '$c' '$dst'"
        say "command: installed $name"
      fi
    done
  fi

  # v2 — agent-neutral sync (core/AGENTS.md block + core/mcp catalog for this agent)
  if [[ "$DRY_RUN" -eq 1 ]]; then
    say "agentic_sync: would run --apply --only claude-code"
  else
    python3 "$BUNDLE_DIR/scripts/agentic_sync.py" --apply --only claude-code \
      || warn "agentic_sync failed (python3 required)"
  fi

  say "done. Next: start a new Claude Code session to load merged settings."
  say "Review: diff against backups in $CLAUDE_DIR/*.bak.*"
fi

# ======================================================
# PROJECT SCOPE
# ======================================================
if [[ "$MODE" == "project" ]]; then
  [[ -z "$TARGET" ]] && { echo "error: project mode needs a target path"; usage; exit 1; }
  [[ ! -d "$TARGET" ]] && { echo "error: $TARGET is not a directory"; exit 1; }
  TARGET="$(cd "$TARGET" && pwd)"
  say "Project scope → $TARGET/"

  do_run "mkdir -p '$TARGET/.claude/agents' '$TARGET/.claude/commands' '$TARGET/.claude/hooks'"

  # CLAUDE.md — managed block append
  install_managed_md "$TARGET/CLAUDE.md" "$BUNDLE_DIR/project/CLAUDE.md"

  # AGENTS.md — symlinked to CLAUDE.md (cross-tool convention for Codex, Cursor, OpenCode)
  if [[ ! -e "$TARGET/AGENTS.md" ]]; then
    do_run "ln -s CLAUDE.md '$TARGET/AGENTS.md'"
    say "AGENTS.md: symlinked to CLAUDE.md (cross-tool compatibility)"
  elif [[ -L "$TARGET/AGENTS.md" ]]; then
    : # existing symlink is fine
  else
    say "AGENTS.md: exists as a regular file — leaving untouched"
  fi

  # settings.json — deep merge
  target="$TARGET/.claude/settings.json"
  backup_if_exists "$target"
  merged="$(merge_json "${target:-/dev/null}" "$BUNDLE_DIR/project/.claude/settings.json")"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    say "project settings.json: would merge (first 20 lines):"
    echo "$merged" | head -20 | sed 's/^/     /'
  else
    echo "$merged" > "$target"
    say "project settings.json: merged"
  fi

  # Scaffolding stubs
  [[ ! -f "$TARGET/.claude/agents/.gitkeep" ]] && do_run "cp '$BUNDLE_DIR/project/.claude/agents/.gitkeep' '$TARGET/.claude/agents/.gitkeep'"
  [[ ! -f "$TARGET/.claude/commands/.gitkeep" ]] && do_run "cp '$BUNDLE_DIR/project/.claude/commands/.gitkeep' '$TARGET/.claude/commands/.gitkeep'"
  for h in "$BUNDLE_DIR"/project/.claude/hooks/*.example; do
    [[ -f "$h" ]] || continue
    name="$(basename "$h")"
    [[ ! -f "$TARGET/.claude/hooks/$name" ]] && do_run "cp '$h' '$TARGET/.claude/hooks/$name'"
  done

  # .gitignore merge
  if [[ -f "$TARGET/.gitignore" ]]; then
    merge_gitignore "$TARGET/.gitignore" "$BUNDLE_DIR/user/.gitignore"
  else
    say ".gitignore: creating from bundle template"
    do_run "cp '$BUNDLE_DIR/user/.gitignore' '$TARGET/.gitignore'"
  fi

  say "done. Open $TARGET/CLAUDE.md and fill the TODO markers."
fi

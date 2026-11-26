#!/usr/bin/env bash
# install.sh - copy (or link) the skills in ./skills into the skill folders of your coding agents.
#
# DEFAULT IS A DRY RUN: without --apply this script only PRINTS what it would do.
# It makes no network calls, never edits agent settings, instruction files or MCP configs,
# and never installs system tools (see tools/ for manifests; --install-tools only prints them
# unless combined with --apply, and then still asks before each package manager command).
#
# Usage:
#   ./install.sh [--agents LIST] [--skills LIST] [--mode copy|link] [--update] [--apply]
#                [--target DIR] [--install-tools] [--list-agents] [--list-skills]
#
#   --agents LIST    comma list of: shared,claude,omp,opencode,codex,gemini,antigravity,cursor,hermes,copilot,windsurf
#                    (default: shared). "shared" = ~/.agents/skills, read by several agents (see tools/agents/*.json).
#   --skills LIST    comma list of skill names, or "all" (default: all). Dependencies listed in skills/index.json are added.
#   --mode           copy (default) or link (symlinks to this checkout; edits here affect every agent).
#   --update         replace an existing skill folder. The old one is MOVED to a sibling folder that agents do not scan:
#                    <skills-dir>-backups/YYYYMMDD/<name>. Without --update, existing folders are skipped.
#   --target DIR     install into DIR instead of the agent folders (for testing).
#   --apply          really do it.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SRC="$HERE/skills"
AGENTS="shared"; SKILLS="all"; MODE="copy"; APPLY=0; UPDATE=0; TARGET=""; TOOLS=0; LIST_AGENTS=0; LIST_SKILLS=0
STAMP="$(date +%Y%m%d)"

while [ $# -gt 0 ]; do
  case "$1" in
    --agents) AGENTS="${2:?}"; shift 2 ;;
    --skills) SKILLS="${2:?}"; shift 2 ;;
    --mode) MODE="${2:?}"; shift 2 ;;
    --target) TARGET="${2:?}"; shift 2 ;;
    --update) UPDATE=1; shift ;;
    --apply) APPLY=1; shift ;;
    --install-tools) TOOLS=1; shift ;;
    --list-agents) LIST_AGENTS=1; shift ;;
    --list-skills) LIST_SKILLS=1; shift ;;
    -h|--help) sed -n '2,24p' "$0"; exit 0 ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
done
case "$MODE" in copy|link) ;; *) echo "--mode must be copy or link" >&2; exit 2 ;; esac

agent_dir() {
  case "$1" in
    shared)      echo "$HOME/.agents/skills" ;;
    claude)      echo "$HOME/.claude/skills" ;;
    omp)         echo "$HOME/.omp/agent/skills" ;;
    opencode)    echo "$HOME/.config/opencode/skills" ;;
    codex)       echo "$HOME/.codex/skills" ;;
    gemini)      echo "$HOME/.gemini/skills" ;;
    antigravity) echo "$HOME/.gemini/config/skills" ;;
    cursor)      echo "$HOME/.cursor/skills" ;;
    hermes)      echo "${HERMES_HOME:-$HOME/.hermes}/skills" ;;
    copilot)     echo "$HOME/.copilot/skills" ;;
    windsurf)    echo "$HOME/.codeium/windsurf/skills" ;;
    *) return 1 ;;
  esac
}
ALL_AGENTS="shared claude omp opencode codex gemini antigravity cursor hermes copilot windsurf"

all_skill_names() { for d in "$SKILLS_SRC"/*/; do [ -f "$d/SKILL.md" ] && basename "$d"; done; }

if [ "$LIST_AGENTS" = 1 ]; then for a in $ALL_AGENTS; do printf '%-12s %s\n' "$a" "$(agent_dir "$a")"; done; exit 0; fi
if [ "$LIST_SKILLS" = 1 ]; then all_skill_names; exit 0; fi

# --- resolve skill list (+ dependencies from skills/index.json when python3 is available) ---
if [ "$SKILLS" = all ]; then SEL="$(all_skill_names | tr '\n' ' ')"; else SEL="$(echo "$SKILLS" | tr ',' ' ')"; fi
if command -v python3 >/dev/null 2>&1 && [ -f "$SKILLS_SRC/index.json" ]; then
  SEL="$(python3 - "$SKILLS_SRC/index.json" $SEL <<'PY'
import json, sys
idx = {s["name"]: s for s in json.load(open(sys.argv[1], encoding="utf-8"))["skills"]}
out, todo = [], list(sys.argv[2:])
while todo:
    n = todo.pop(0)
    if n in out:
        continue
    if n not in idx:
        sys.stderr.write("unknown skill: %s\n" % n); sys.exit(3)
    out.append(n)
    todo += idx[n].get("requires", [])
print(" ".join(out))
PY
)"
fi
for s in $SEL; do [ -f "$SKILLS_SRC/$s/SKILL.md" ] || { echo "unknown skill: $s" >&2; exit 3; }; done

if [ "$APPLY" = 1 ]; then echo "== APPLY mode =="; else echo "== DRY RUN (nothing will be written; add --apply to execute) =="; fi
echo "skills: $(echo $SEL | wc -w) | mode: $MODE | update: $UPDATE"

do_one() {  # agent-label dest-root
  local label="$1" root="$2" s dest
  echo "-- $label -> $root"
  if [ ! -d "$root" ]; then
    if [ "$APPLY" = 1 ]; then mkdir -p "$root"; else echo "   would create $root"; fi
  fi
  for s in $SEL; do
    dest="$root/$s"
    if [ -e "$dest" ] || [ -L "$dest" ]; then
      if [ "$UPDATE" = 1 ]; then
        echo "   $s: exists -> move old copy to ${root}-backups/$STAMP/$s, then $MODE"
        if [ "$APPLY" = 1 ]; then
          mkdir -p "${root}-backups/$STAMP"
          mv "$dest" "${root}-backups/$STAMP/$s"
        else continue; fi
      else
        echo "   $s: exists -> skip (use --update to replace with backup)"; continue
      fi
    else
      echo "   $s: new -> $MODE"
    fi
    if [ "$APPLY" = 1 ]; then
      if [ "$MODE" = link ]; then ln -s "$SKILLS_SRC/$s" "$dest"; else cp -R "$SKILLS_SRC/$s" "$dest"; fi
    fi
  done
}

if [ -n "$TARGET" ]; then
  do_one "custom" "$TARGET"
else
  for a in $(echo "$AGENTS" | tr ',' ' '); do
    d="$(agent_dir "$a")" || { echo "unknown agent: $a (see --list-agents)" >&2; exit 2; }
    do_one "$a" "$d"
  done
fi

# --- tools: print-only unless --apply, never automatic ---
if [ "$TOOLS" = 1 ]; then
  echo
  echo "== tools (manifests in tools/os/) =="
  case "$(uname -s)" in
    Darwin) echo "macOS: brew bundle --file=tools/os/Brewfile" ;;
    Linux)
      if command -v apt-get >/dev/null 2>&1; then echo "Debian/Ubuntu: xargs -a tools/os/debian-apt.txt sudo apt-get install -y"
      elif command -v dnf >/dev/null 2>&1; then echo "Fedora/RHEL: xargs -a tools/os/fedora-dnf.txt sudo dnf install -y"
      else echo "Linux: no apt/dnf found; see tools/manifest.json for the package names"; fi ;;
    *) echo "Windows: use install.ps1 (winget import -i tools/os/windows-winget.json)" ;;
  esac
  echo "npm/pip globals: tools/os/npm-global.txt, tools/os/pipx.txt"
  if [ "$APPLY" = 1 ]; then echo "(--install-tools never runs package managers for you: run the printed command yourself after reading the manifest)"; fi
fi

if [ "$APPLY" != 1 ]; then echo; echo "Dry run finished. Nothing was changed."; else echo; echo "Done. Start a new agent session to load the skills."; fi

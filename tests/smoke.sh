#!/usr/bin/env bash
# tests/smoke.sh — smoke tests for the universal-agentic-setup entrypoints.
# Runs ./setup --doctor and ./setup --dry-run --yes against an isolated $HOME.
# Exits 0 if all expected lines are present, non-zero otherwise.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TMPHOME="$(mktemp -d -t uas-smoke-XXXXXX)"
TMPOUT="$(mktemp -t uas-smoke-out-XXXXXX)"
# Full sandbox: redirect every home-ish variable for the WHOLE suite so no
# child process (hooks, installers, python) can touch the real home.
export HOME="$TMPHOME"
export USERPROFILE="$TMPHOME"
export APPDATA="$TMPHOME/AppData/Roaming"
export XDG_CONFIG_HOME="$TMPHOME/.config"
export UNIVERSAL_AGENTIC_HOME="$TMPHOME"
PASS=0
FAIL=0

cleanup() { rm -rf "$TMPHOME" "$TMPOUT"; }
trap cleanup EXIT

ok()   { printf '  ✓ %s\n' "$1"; PASS=$((PASS+1)); }
bad()  { printf '  ✗ %s\n' "$1" >&2; FAIL=$((FAIL+1)); }
contains() {
  local label="$1" file="$2" needle="$3"
  if grep -qF -- "$needle" "$file" 2>/dev/null; then ok "$label"; else bad "$label"; fi
}

echo "=== universal-agentic-setup smoke test ==="
echo "  REPO:    $REPO_DIR"
echo "  TMPHOME: $TMPHOME"

# T1 — version
echo
echo "--- T1: --version ---"
if "$REPO_DIR/setup" --version > "$TMPOUT" 2>&1; then ok "version exits 0"; else bad "version exits 0"; fi
expected="universal-agentic-setup $(cat "$REPO_DIR/VERSION")"
if [[ "$(cat "$TMPOUT")" = "$expected" ]]; then ok "version matches VERSION file"; else bad "version matches VERSION file"; fi

# T2 — help
echo
echo "--- T2: --help ---"
if "$REPO_DIR/setup" --help > "$TMPOUT" 2>&1; then ok "help exits 0"; else bad "help exits 0"; fi
contains "help contains Usage:" "$TMPOUT" "Usage:"

# T3 — doctor (isolated HOME)
echo
echo "--- T3: --doctor ---"
if HOME="$TMPHOME" "$REPO_DIR/setup" --doctor > "$TMPOUT" 2>&1; then ok "doctor exits 0"; else bad "doctor exits 0"; fi
contains "doctor reports environment" "$TMPOUT" "Detected environment"

# T4 — dry-run + yes through all 8 phases
echo
echo "--- T4: --dry-run --yes ---"
if HOME="$TMPHOME" "$REPO_DIR/setup" --dry-run --yes > "$TMPOUT" 2>&1; then ok "dry-run exits 0"; else bad "dry-run exits 0"; fi
contains "dry-run reaches phase 1" "$TMPOUT" "1/8"
contains "dry-run reaches phase 8" "$TMPOUT" "8/8"
if [[ ! -f "$TMPHOME/.universal-agentic-manifest.json" ]]; then ok "dry-run did NOT write manifest"; else bad "dry-run did NOT write manifest"; fi

# T5 — install.sh user --dry-run
echo
echo "--- T5: install.sh user --dry-run ---"
if HOME="$TMPHOME" bash "$REPO_DIR/install.sh" --dry-run user > "$TMPOUT" 2>&1; then ok "install.sh exits 0"; else bad "install.sh exits 0"; fi
contains "install.sh reports user scope" "$TMPOUT" "User scope"

# T6 — skill-router on a known prompt (use isolated HOME so dedup state is fresh)
echo
echo "--- T6: skill-router.sh ---"
HOME="$TMPHOME" printf '%s' '{"prompt":"plan a railway deployment"}' \
  | HOME="$TMPHOME" "$REPO_DIR/user/hooks/skill-router.sh" > "$TMPOUT" 2>&1 || true
contains "router emits Skill hints header" "$TMPOUT" "Skill hints"
contains "router suggests plan skill"      "$TMPOUT" "\`plan\`"

# T7 — skill-router silent on short prompts (also isolated HOME)
echo
echo "--- T7: skill-router silent on short prompt ---"
HOME="$TMPHOME/t7" mkdir -p "$TMPHOME/t7"
HOME="$TMPHOME/t7" printf '%s' '{"prompt":"hi"}' \
  | HOME="$TMPHOME/t7" "$REPO_DIR/user/hooks/skill-router.sh" > "$TMPOUT" 2>&1 || true
if [[ ! -s "$TMPOUT" ]]; then ok "router silent on short prompt"; else bad "router silent on short prompt"; fi

# T8 — agentic_sync doctor against an isolated home
echo
echo "--- T8: agentic_sync.py --doctor ---"
if HOME="$TMPHOME" python3 "$REPO_DIR/scripts/agentic_sync.py" --doctor > "$TMPOUT" 2>&1; then ok "doctor exits 0"; else bad "doctor exits 0"; fi
contains "doctor counts the registry" "$TMPOUT" "26 in registry"

# T9 — agentic_sync apply + uninstall round-trip in an isolated home
echo
echo "--- T9: agentic_sync.py apply + uninstall ---"
if HOME="$TMPHOME" python3 "$REPO_DIR/scripts/agentic_sync.py" --apply --only cursor > "$TMPOUT" 2>&1; then ok "apply exits 0"; else bad "apply exits 0"; fi
if [[ -f "$TMPHOME/.cursor/mcp.json" ]]; then ok "apply wrote .cursor/mcp.json"; else bad "apply wrote .cursor/mcp.json"; fi
if grep -q '"duckduckgo"' "$TMPHOME/.cursor/mcp.json" 2>/dev/null; then ok "mcp catalog merged"; else bad "mcp catalog merged"; fi
if HOME="$TMPHOME" python3 "$REPO_DIR/scripts/agentic_sync.py" --uninstall --apply > "$TMPOUT" 2>&1; then ok "uninstall exits 0"; else bad "uninstall exits 0"; fi
if [[ ! -f "$TMPHOME/.cursor/mcp.json" ]]; then ok "uninstall removed created file"; else bad "uninstall removed created file"; fi

# T10 — python unittest suite
echo
echo "--- T10: python unittest suite ---"
if (cd "$REPO_DIR" && python3 -m unittest discover -s tests > "$TMPOUT" 2>&1); then ok "unittest suite passes"; else bad "unittest suite passes"; tail -20 "$TMPOUT" >&2; fi

# Summary
echo
echo "=== summary: $PASS pass, $FAIL fail ==="
[[ "$FAIL" -eq 0 ]]

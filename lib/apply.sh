#!/usr/bin/env bash
# lib/apply.sh — idempotent apply phase. Calls existing scripts in order.

# Internal: should we skip a named step?
_should_skip() {
  local step="$1"
  [[ ",${SETUP_SKIP:-}," == *",${step},"* ]]
}

# Internal: is "only=user" set?
_only_user() {
  [[ "${SETUP_ONLY:-}" = "user" ]]
}

apply_user_scope() {
  step "1/8 — apply user-scope config"
  if [[ "$SETUP_DRY" -eq 1 ]]; then
    bash "$BUNDLE_DIR/install.sh" --dry-run user 2>&1 | sed 's/^/    /' | tail -10
  else
    bash "$BUNDLE_DIR/install.sh" user 2>&1 | tail -10
  fi
}

apply_skills() {
  _only_user && { hint "skip skills (--only=user)"; return; }
  _should_skip skills && { hint "skip skills (--skip)"; return; }
  step "2/8 — install design-skill family"
  if [[ "$SETUP_DRY" -eq 1 ]]; then
    hint "(dry-run) bash install-skills.sh"
  else
    bash "$BUNDLE_DIR/install-skills.sh" 2>&1 | tail -5 || warn "install-skills exited non-zero"
  fi
}

apply_scaffolding() {
  _only_user && { hint "skip scaffolding (--only=user)"; return; }
  _should_skip scaffolding && { hint "skip scaffolding (--skip)"; return; }
  step "3/8 — init llm-wiki + improvement-state"
  for s in init-llm-wiki.sh init-improvement-state.sh bootstrap-resources.sh; do
    if [[ "$SETUP_DRY" -eq 1 ]]; then
      hint "(dry-run) bash scripts/$s"
    else
      bash "$BUNDLE_DIR/scripts/$s" 2>&1 | tail -2 || warn "$s exited non-zero"
    fi
  done
}

apply_cross_tool_sync() {
  _only_user && { hint "skip agent sync (--only=user)"; return; }
  _should_skip sync && { hint "skip agent sync (--skip)"; return; }
  step "4/8 — wire every detected agent (agentic_sync.py)"
  local mode=""; [[ "$SETUP_DRY" -eq 1 ]] || mode="--apply"
  local py_bin="python3"
  command -v python3 >/dev/null 2>&1 || py_bin="python"
  command -v "$py_bin" >/dev/null 2>&1 || { warn "no python on PATH — agent sync skipped"; return; }
  "$py_bin" "$BUNDLE_DIR/scripts/agentic_sync.py" $mode 2>&1 | tail -20 || warn "agent sync exited non-zero"
}

apply_addons() {
  _only_user && { hint "skip add-ons (--only=user)"; return; }
  local with="${SETUP_WITH:-}"
  [[ -z "$with" ]] && { hint "no add-ons requested"; return; }
  step "5/8 — opt-in add-ons: $with"
  IFS=',' read -ra addons <<< "$with"
  for addon in "${addons[@]}"; do
    addon="$(echo "$addon" | xargs)"  # trim
    local script="$BUNDLE_DIR/scripts/install-${addon}.sh"
    if [[ ! -x "$script" ]]; then
      warn "add-on '$addon' not found ($script)"
      continue
    fi
    say "installing add-on: $addon"
    if [[ "$SETUP_DRY" -eq 1 ]]; then
      hint "(dry-run) bash $script"
    else
      bash "$script" 2>&1 | tail -10 || warn "$addon installer exited non-zero"
    fi
  done
}

apply_manifest() {
  step "6/8 — write manifest"
  local manifest="$HOME/.universal-agentic-manifest.json"
  if [[ "$SETUP_DRY" -eq 1 ]]; then
    hint "(dry-run) write $manifest"
    return
  fi
  # Merge setup state into the v2 manifest (agents section is owned by
  # agentic_sync.py — never clobbered here).
  MANIFEST="$manifest" VERSION="$VERSION" BUNDLE_DIR="$BUNDLE_DIR" \
  SETUP_WITH="${SETUP_WITH:-}" OS="$OS" DISTRO="$DISTRO" ARCH="$ARCH" \
  python3 - <<'PYEOF'
import json, os, datetime
path = os.environ["MANIFEST"]
try:
    data = json.load(open(path, encoding="utf-8"))
except Exception:
    data = {}
data.update({
    "name": "universal-agentic-setup",
    "version": os.environ["VERSION"],
    "installed_at": data.get("installed_at") or datetime.datetime.now(datetime.timezone.utc).isoformat(timespec="seconds"),
    "updated_at": datetime.datetime.now(datetime.timezone.utc).isoformat(timespec="seconds"),
    "bundle_dir": os.environ["BUNDLE_DIR"],
    "addons": os.environ.get("SETUP_WITH", ""),
    "host": {"os": os.environ["OS"], "distro": os.environ["DISTRO"], "arch": os.environ["ARCH"]},
})
with open(path, "w", encoding="utf-8", newline="\n") as fh:
    json.dump(data, fh, indent=2)
    fh.write("\n")
PYEOF
  ok "manifest: $manifest"
}

apply_all() {
  apply_user_scope
  apply_skills
  apply_scaffolding
  apply_cross_tool_sync
  apply_addons
  apply_manifest
}

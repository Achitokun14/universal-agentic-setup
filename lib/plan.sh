#!/usr/bin/env bash
# lib/plan.sh — pretty-print the change plan based on detected state.

plan_print() {
  step "Detected environment"
  printf '  OS:           %s/%s (%s, %s)\n' "$OS" "$DISTRO" "$OS_VARIANT" "$ARCH"
  printf '  Pkg manager:  %s\n' "$PKG"
  printf '  Shell:        %s (rc: %s)\n' "$SHELL_NAME" "$SHELL_RC"
  printf '  Bundle state: %s%s\n' "$BUNDLE_STATE" \
    "$([[ -n "$INSTALLED_VERSION" ]] && echo " (installed: $INSTALLED_VERSION → target: $VERSION)")"

  step "Helper tools"
  printf '  jq:      %s\n' "$HAVE_JQ"
  printf '  python3: %s\n' "$HAVE_PY"
  printf '  node:    %s\n' "$HAVE_NODE"
  printf '  npm:     %s\n' "$HAVE_NPM"
  printf '  git:     %s\n' "$HAVE_GIT"
  printf '  curl:    %s\n' "$HAVE_CURL"

  step "AI coding CLIs detected"
  printf '  claude:    %s\n' "$CLI_CLAUDE"
  printf '  codex:     %s\n' "$CLI_CODEX"
  printf '  goose:     %s\n' "$CLI_GOOSE"
  printf '  gemini:    %s\n' "$CLI_GEMINI"
  printf '  kimi:      %s\n' "$CLI_KIMI"
  printf '  opencode:  %s\n' "$CLI_OPENCODE"
  printf '  claw:      %s\n' "$CLI_CLAW"

  step "Plan"
  case "$BUNDLE_STATE" in
    fresh)
      echo "  1. install bundle-runtime prereqs if missing"
      echo "  2. apply user-scope config to ~/.claude/ (idempotent merge)"
      echo "  3. install design skills family (~/.claude/skills/)"
      echo "  4. init llm-wiki + improvement-state scaffolding"
      echo "  5. wire every detected agent (scripts/agentic_sync.py: rules + MCP)"
      echo "  6. install opt-in add-ons: ${SETUP_WITH:-none requested}"
      echo "  7. write manifest to ~/.universal-agentic-manifest.json"
      echo "  8. verify each agent (smoke checks)"
      ;;
    installed)
      if [[ "$INSTALLED_VERSION" = "$VERSION" ]]; then
        echo "  bundle is up-to-date ($VERSION) — verify-only pass"
      else
        echo "  upgrade $INSTALLED_VERSION → $VERSION"
        echo "  1. re-apply user-scope config (managed-block refresh)"
        echo "  2. re-run cross-tool sync"
        echo "  3. update manifest version"
      fi
      ;;
  esac

  if [[ -n "${SETUP_SKIP:-}" ]]; then
    hint "skipping: $SETUP_SKIP"
  fi
  if [[ "${SETUP_ONLY:-}" = "user" ]]; then
    hint "--only=user: skipping skills, llm-wiki, agent sync, add-ons"
  fi
}

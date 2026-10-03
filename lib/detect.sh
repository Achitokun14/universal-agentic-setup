#!/usr/bin/env bash
# lib/detect.sh — detect OS, pkg-manager, shell, AI CLIs. Exports vars.

detect_os() {
  case "$(uname -s)" in
    Linux*)
      OS=linux
      if [[ -f /etc/os-release ]]; then
        # Subshell-isolated read so /etc/os-release doesn't clobber our env (e.g. VERSION)
        DISTRO="$(. /etc/os-release && echo "$ID")"
      else
        DISTRO=unknown
      fi
      # WSL?
      grep -qi microsoft /proc/version 2>/dev/null && OS_VARIANT=wsl || OS_VARIANT=native
      ;;
    Darwin*) OS=macos; DISTRO=macos; OS_VARIANT=native ;;
    CYGWIN*|MINGW*|MSYS*) OS=windows; DISTRO=windows; OS_VARIANT=native ;;
    *) OS=unknown; DISTRO=unknown; OS_VARIANT=unknown ;;
  esac
  ARCH="$(uname -m)"
  case "$ARCH" in
    x86_64|amd64) ARCH=amd64 ;;
    aarch64|arm64) ARCH=arm64 ;;
  esac
}

detect_pkg_manager() {
  if   command -v apt-get >/dev/null 2>&1; then PKG=apt
  elif command -v dnf     >/dev/null 2>&1; then PKG=dnf
  elif command -v pacman  >/dev/null 2>&1; then PKG=pacman
  elif command -v zypper  >/dev/null 2>&1; then PKG=zypper
  elif command -v apk     >/dev/null 2>&1; then PKG=apk
  elif command -v brew    >/dev/null 2>&1; then PKG=brew
  else PKG=none
  fi
}

detect_shell() {
  case "${SHELL:-}" in
    *zsh*)  SHELL_NAME=zsh;  SHELL_RC="$HOME/.zshrc" ;;
    *bash*) SHELL_NAME=bash; SHELL_RC="$HOME/.bashrc" ;;
    *fish*) SHELL_NAME=fish; SHELL_RC="$HOME/.config/fish/config.fish" ;;
    *)      SHELL_NAME=bash; SHELL_RC="$HOME/.bashrc" ;;
  esac
}

# ai_cli_present "claude" → echoes "claude 2.1.116" if present, "missing" otherwise
ai_cli_present() {
  local name="$1"
  if command -v "$name" >/dev/null 2>&1; then
    local v
    v="$("$name" --version 2>/dev/null | head -1 || echo '?')"
    echo "${name} ${v}"
  else
    echo "missing"
  fi
}

detect_ai_clis() {
  CLI_CLAUDE=$(ai_cli_present claude)
  CLI_CODEX=$(ai_cli_present codex)
  CLI_GOOSE=$(ai_cli_present goose)
  CLI_GEMINI=$(ai_cli_present gemini)
  CLI_KIMI=$(ai_cli_present kimi)
  CLI_OPENCODE=$(ai_cli_present opencode)
  CLI_CLAW=$(ai_cli_present claw)
}

# Helper tools
detect_helpers() {
  HAVE_JQ=$(command -v jq      >/dev/null 2>&1 && echo yes || echo no)
  HAVE_PY=$(command -v python3 >/dev/null 2>&1 && echo yes || echo no)
  HAVE_NODE=$(command -v node  >/dev/null 2>&1 && echo yes || echo no)
  HAVE_NPM=$(command -v npm    >/dev/null 2>&1 && echo yes || echo no)
  HAVE_GIT=$(command -v git    >/dev/null 2>&1 && echo yes || echo no)
  HAVE_CURL=$(command -v curl  >/dev/null 2>&1 && echo yes || echo no)
}

# Detect already-installed bundle (for update vs install path)
detect_bundle_state() {
  local manifest="$HOME/.universal-agentic-manifest.json"
  local legacy="$HOME/.claude/.claude-universal-manifest.json"
  if [[ -f "$manifest" ]]; then
    INSTALLED_VERSION="$(jq -r '.version // "unknown"' "$manifest" 2>/dev/null || echo unknown)"
    BUNDLE_STATE=installed
  elif [[ -f "$legacy" ]]; then
    INSTALLED_VERSION="$(jq -r '.version // "unknown"' "$legacy" 2>/dev/null || echo unknown)"
    BUNDLE_STATE=installed
    say "v1 manifest found ($legacy, version $INSTALLED_VERSION) — see MIGRATION.md"
  else
    INSTALLED_VERSION=""
    BUNDLE_STATE=fresh
  fi
}

detect_all() {
  detect_os
  detect_pkg_manager
  detect_shell
  detect_ai_clis
  detect_helpers
  detect_bundle_state
}

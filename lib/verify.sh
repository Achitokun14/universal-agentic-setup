#!/usr/bin/env bash
# lib/verify.sh — post-install smoke checks. One PASS/FAIL line per agent.

verify_one() {
  local name="$1" cmd="$2"
  if eval "$cmd" >/dev/null 2>&1; then
    ok "$name"
  else
    warn "$name (not installed or failing)"
  fi
}

_check_if_present() {
  # Run verify_one only when the binary exists. Wrapped in if/fi so a missing
  # binary doesn't make the line return non-zero (which set -e would catch).
  local bin="$1" name="$2" cmd="$3"
  if command -v "$bin" >/dev/null 2>&1; then
    verify_one "$name" "$cmd"
  fi
}

verify_all() {
  step "7/8 — verify"

  # Bundle artefacts
  verify_one "manifest exists"          "test -f $HOME/.universal-agentic-manifest.json"
  verify_one "settings.json present"    "test -f $HOME/.claude/settings.json"
  verify_one "managed CLAUDE.md block"  "grep -q 'BEGIN: universal-agentic-setup managed block' $HOME/.claude/CLAUDE.md"
  verify_one "managed AGENTS.md block"  "grep -q 'BEGIN: universal-agentic-setup managed block' $HOME/.claude/AGENTS.md"
  verify_one "skill-router hook wired"  "jq -e '.hooks.UserPromptSubmit[].hooks[]?.command | select(test(\"skill-router.sh\"))' $HOME/.claude/settings.json"

  # AI CLIs (only if present)
  _check_if_present claude   "claude --version"   "claude --version"
  _check_if_present codex    "codex --version"    "codex --version"
  _check_if_present goose    "goose --version"    "goose --version"
  _check_if_present gemini   "gemini --version"   "gemini --version"
  _check_if_present kimi     "kimi --version"     "kimi --version"
  _check_if_present opencode "opencode --version" "opencode --version"

  # Add-ons (only if installed)
  _check_if_present obsidian-cli "obsidian-cli list-vaults" "obsidian-cli list-vaults"
  _check_if_present markitdown   "markitdown --version"     "markitdown --version"
  return 0
}

verify_doctor() {
  # Doctor mode: same as verify, but also report missing CLIs and suggest installs.
  verify_all
  step "Doctor — suggested next steps"
  command -v claude   >/dev/null 2>&1 || hint "Claude Code not found. Install: https://docs.claude.com/claude-code"
  command -v codex    >/dev/null 2>&1 || hint "Codex not found. Install: npm i -g @openai/codex"
  command -v goose    >/dev/null 2>&1 || hint "Goose not found. Install: curl -fsSL https://block.github.io/goose/install.sh | sh"
  command -v gemini   >/dev/null 2>&1 || hint "Gemini CLI not found. Install: npm i -g @google/gemini-cli"
  command -v kimi     >/dev/null 2>&1 || hint "Kimi CLI not found. Install: pipx install kimi-cli"
  command -v opencode >/dev/null 2>&1 || hint "OpenCode not found. Install: curl -fsSL https://opencode.ai/install | sh"
  command -v ollama   >/dev/null 2>&1 || hint "Ollama not found. Install: bash $BUNDLE_DIR/scripts/install-ollama.sh"
  return 0
}

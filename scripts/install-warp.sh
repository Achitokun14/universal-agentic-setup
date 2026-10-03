#!/usr/bin/env bash
# install-warp.sh — Install Warp terminal on Linux and migrate Alacritty theme/keybinds.
#
# What this does:
#   1. Install `warp-terminal` from the official apt repo (Ubuntu/Debian)
#   2. Translate your current Alacritty config (~/.config/alacritty/alacritty.toml):
#        - colors (primary, normal, bright) → Warp theme YAML
#        - font family + size
#        - blur/transparency hint (Warp's own transparency setting)
#   3. Generate a Warp theme file at ~/.warp/themes/universal-agentic-setup.yaml
#   4. Set up shell aliases that Warp will inherit via your ~/.zshrc
#
# What this does NOT do:
#   - Cannot import Alacritty "blur"/opacity 1-for-1 (Warp's opacity is a slider
#     in settings, not per-config-file; we write a recommended value to a hint file)
#   - Does not migrate keybindings (Warp's keybinds are its own schema; documented below)
#   - Does not enable Warp's telemetry/AI-auto-share (your choice, off by default
#     after first-run)

set -euo pipefail

say() { printf '▸ %s\n' "$*"; }
warn() { printf '⚠ %s\n' "$*" >&2; }

# ── 1. Install warp-terminal ────────────────────────────────────────────
if command -v warp-terminal >/dev/null 2>&1; then
  say "warp-terminal already installed: $(command -v warp-terminal)"
else
  if ! command -v apt-get >/dev/null 2>&1; then
    warn "apt-get not found — this installer assumes Debian/Ubuntu. On other distros, grab the AppImage from https://app.warp.dev/download"
    exit 2
  fi

  say "Adding Warp apt repo (requires sudo)"
  # Per Warp's official docs: https://docs.warp.dev/getting-started/installation-linux
  curl -fsSL https://releases.warp.dev/linux/keys/warp.asc \
    | sudo gpg --dearmor -o /usr/share/keyrings/warp-archive-keyring.gpg
  echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/warp-archive-keyring.gpg] https://releases.warp.dev/linux/deb stable main' \
    | sudo tee /etc/apt/sources.list.d/warp-terminal.list > /dev/null

  sudo apt-get update -qq
  sudo apt-get install -y warp-terminal

  command -v warp-terminal && say "installed: $(command -v warp-terminal)"
fi

# ── 2. Parse Alacritty config ──────────────────────────────────────────
ALAC="$HOME/.config/alacritty/alacritty.toml"
if [[ ! -f "$ALAC" ]]; then
  warn "No Alacritty config at $ALAC — skipping theme migration"
  exit 0
fi

say "Parsing Alacritty config for theme migration"

# Use Python for robust TOML parsing
python3 - <<'PY'
import tomllib, os, json
from pathlib import Path

alac = Path.home() / '.config/alacritty/alacritty.toml'
with open(alac, 'rb') as f:
    cfg = tomllib.load(f)

colors = cfg.get('colors', {})
primary = colors.get('primary', {})
normal  = colors.get('normal', {})
bright  = colors.get('bright', {})
window  = cfg.get('window', {})
font    = cfg.get('font', {}).get('normal', {})

def hex_of(s):
    """'0x0a1f0a' -> '#0a1f0a'"""
    if not s: return None
    s = str(s)
    if s.startswith('0x'): return '#' + s[2:]
    if s.startswith('#'):  return s
    return '#' + s

# Warp theme format: YAML with specific field names
# Reference: https://docs.warp.dev/features/appearance/custom-themes
theme = {
    'name': 'universal-agentic-setup',
    'accent': hex_of(normal.get('green', '0x88C999')),  # mint green — stand-out
    'background': hex_of(primary.get('background', '0x0a1f0a')),
    'foreground': hex_of(primary.get('foreground', '0xe0e0e0')),
    'details': 'darker',
    'terminal_colors': {
        'normal': {
            'black':   hex_of(normal.get('black')),
            'red':     hex_of(normal.get('red')),
            'green':   hex_of(normal.get('green')),
            'yellow':  hex_of(normal.get('yellow')),
            'blue':    hex_of(normal.get('blue')),
            'magenta': hex_of(normal.get('magenta')),
            'cyan':    hex_of(normal.get('cyan')),
            'white':   hex_of(normal.get('white')),
        },
        'bright': {
            'black':   hex_of(bright.get('black')),
            'red':     hex_of(bright.get('red')),
            'green':   hex_of(bright.get('green')),
            'yellow':  hex_of(bright.get('yellow')),
            'blue':    hex_of(bright.get('blue')),
            'magenta': hex_of(bright.get('magenta')),
            'cyan':    hex_of(bright.get('cyan')),
            'white':   hex_of(bright.get('white')),
        },
    },
}

# Serialize as YAML (minimal — avoid external dependencies)
def to_yaml(d, indent=0):
    out = []
    pad = '  ' * indent
    for k, v in d.items():
        if isinstance(v, dict):
            out.append(f'{pad}{k}:')
            out.append(to_yaml(v, indent+1))
        elif v is None:
            continue
        else:
            out.append(f'{pad}{k}: "{v}"')
    return '\n'.join(out)

out_dir = Path.home() / '.warp/themes'
out_dir.mkdir(parents=True, exist_ok=True)
out_path = out_dir / 'universal-agentic-setup.yaml'
out_path.write_text(to_yaml(theme) + '\n')
print(f"✓ wrote {out_path}")

# ── Opacity + font hint file (Warp UI-configured, not file-driven) ────
hint = f"""# Warp settings Alacritty can't auto-apply
# Open Warp → Settings → Appearance and set:
#   Window opacity: ~{int(100 - float(window.get('opacity', 0.1))*100)}%  (Alacritty used {window.get('opacity', 0.1)})
#   Window blur:    {'enabled' if window.get('blur') else 'disabled'}
#   Font:           {font.get('family', 'MesloLGS NF')}
#   Font size:      {cfg.get('font', {}).get('size', 12.0)}
#   Active theme:   universal-agentic-setup  (auto-imported from this install)
"""
hint_path = out_dir / 'UNIVERSAL-AGENTIC-SETUP-README.md'
hint_path.write_text(hint)
print(f"✓ wrote settings hint: {hint_path}")
PY

# ── 3. Shell aliases for AI CLIs (Warp inherits your shell's PATH+aliases) ──
ZSHRC="$HOME/.zshrc"
BLOCK_BEGIN='# BEGIN: universal-agentic-setup AI CLI aliases'
BLOCK_END='# END: universal-agentic-setup AI CLI aliases'

if [[ -f "$ZSHRC" ]]; then
  if ! grep -qF "$BLOCK_BEGIN" "$ZSHRC"; then
    say "Appending AI-CLI aliases block to $ZSHRC"
    cat >> "$ZSHRC" <<EOF

$BLOCK_BEGIN
# Added $(date -u +%Y-%m-%d) by install-warp.sh — edit or remove freely
alias cc='claude'
alias kc='kimi'
alias oc='opencode'
alias zc='zeroclaw'
alias cw='claw'
# Source claw-code env if installed (reads CLAW_API_KEY + CLAW_API_BASE_URL)
[[ -f "\$HOME/.config/claw/env.sh" ]] && source "\$HOME/.config/claw/env.sh"
$BLOCK_END
EOF
  else
    say "Aliases block already in $ZSHRC — skipped"
  fi
fi

# ── 4. Final instructions ───────────────────────────────────────────────
cat <<'DONE'

✓ Warp installed and theme migrated.

NEXT STEPS (manual — Warp's opacity/blur/font/keybinds aren't file-configurable):

  1. Launch Warp:
       warp-terminal &

  2. First-run wizard:
       - Decline "command sharing" / "AI auto-share" if you don't want telemetry
       - Log in is OPTIONAL — Warp works without an account (some AI features are gated behind it)

  3. Apply the migrated theme:
       Settings → Appearance → Themes → "universal-agentic-setup" (auto-imported from ~/.warp/themes/)

  4. Manually set the UI-only bits per your Alacritty config (values in
     ~/.warp/themes/UNIVERSAL-AGENTIC-SETUP-README.md):
       - Window opacity ~90%
       - Window blur: on
       - Font: MesloLGS NF, size 12

  5. Keybinds (not auto-migrated — Alacritty keybinds don't translate directly):
       - Ctrl+Shift+C/V: Copy/Paste    (Warp default — matches Alacritty)
       - Alt+Enter: Toggle fullscreen  (set via Settings → Keyboard Shortcuts)
       - Super+Q: Quit                  (default usually ⌘Q; adjust to taste)

Notes:
  - All your CLIs (claude, kimi, opencode, zeroclaw, claw) work identically in Warp.
    Aliases cc/kc/oc/zc/cw were added to ~/.zshrc.
  - claw-code env is auto-sourced on shell start (if installed).
  - Warp's built-in AI is SEPARATE from Claude Code — it uses Warp's own API;
    configure in Settings → AI if you want it enabled.
DONE

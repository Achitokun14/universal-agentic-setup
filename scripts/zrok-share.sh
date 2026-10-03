#!/usr/bin/env bash
# zrok-share.sh — Start a zrok public share for ZeroClaw gateway, write URL to config.
#
# Replaces legacy ngrok flow. zrok = OpenZiti overlay network, zrok.io hosted or self-hosted.
#
# Usage:
#   zrok-share.sh               # share gateway port from ~/.zeroclaw/config.toml [gateway]
#   zrok-share.sh <port>        # share arbitrary local port
#   zrok-share.sh --stop        # kill background share
#
# Prereqs (one-time, interactive):
#   1. zrok invite <you@email>                          # request account at zrok.io
#   2. zrok enable <invite-token>                        # binds this machine to account
#   3. zrok reserve public --backend-mode proxy 0.0.0.0:PORT   # optional stable subdomain

set -euo pipefail

ZEROCLAW_CFG="$HOME/.zeroclaw/config.toml"
STATE="$HOME/.zeroclaw/zrok.state"

say() { printf '▸ %s\n' "$*"; }
warn() { printf '⚠ %s\n' "$*" >&2; }

if ! command -v zrok >/dev/null 2>&1; then
  warn "zrok not on PATH. Install: bash universal-agentic-setup/scripts/install-zrok.sh"
  exit 2
fi

# ── stop path ─────────────────────────────────────────────────────
if [[ "${1:-}" == "--stop" ]]; then
  if [[ -f "$STATE" ]]; then
    pid=$(jq -r .pid "$STATE" 2>/dev/null || grep -oP 'pid=\K[0-9]+' "$STATE")
    kill "$pid" 2>/dev/null && say "killed zrok share (pid=$pid)" || warn "no process at pid $pid"
    rm -f "$STATE"
  fi
  exit 0
fi

# ── port determination ────────────────────────────────────────────
PORT="${1:-}"
if [[ -z "$PORT" && -f "$ZEROCLAW_CFG" ]]; then
  PORT="$(awk '/^\[gateway\]/,/^\[/ { if ($1 == "port") { print $3; exit } }' "$ZEROCLAW_CFG")"
fi
PORT="${PORT:-42617}"
say "sharing localhost:$PORT via zrok"

# ── ensure zrok enabled ───────────────────────────────────────────
if ! zrok status 2>&1 | grep -qE "api_endpoint|account"; then
  warn "zrok not enabled on this machine."
  warn "Run: zrok invite <your-email>   then   zrok enable <token-from-email>"
  exit 3
fi

# ── start share in background, capture public URL ─────────────────
LOG="$HOME/.zeroclaw/zrok.log"
mkdir -p "$(dirname "$LOG")"

# Public share, proxy backend, ephemeral subdomain
nohup zrok share public --backend-mode proxy --headless "http://127.0.0.1:$PORT" \
  > "$LOG" 2>&1 &
PID=$!

# Wait for zrok to print the share URL (appears within a few seconds)
say "waiting for share URL..."
URL=""
for _ in $(seq 1 30); do
  sleep 1
  URL="$(grep -oE 'https://[a-zA-Z0-9-]+\.share\.zrok\.io' "$LOG" | head -1)"
  [[ -n "$URL" ]] && break
done

if [[ -z "$URL" ]]; then
  warn "could not extract share URL from zrok output"
  warn "check log: $LOG"
  kill "$PID" 2>/dev/null || true
  exit 4
fi

say "zrok public URL: $URL"

# ── persist state ─────────────────────────────────────────────────
cat > "$STATE" <<JSON
{"pid": $PID, "url": "$URL", "local_port": $PORT, "started": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"}
JSON

# ── patch zeroclaw config.toml ────────────────────────────────────
if [[ -f "$ZEROCLAW_CFG" ]]; then
  # Replace existing `url = "custom:https://...."` under [tunnel]
  python3 - "$ZEROCLAW_CFG" "$URL" <<'PY'
import sys, re
path, url = sys.argv[1], sys.argv[2]
text = open(path).read()
# Find [tunnel] block, update url= line
def repl(m):
    block = m.group(0)
    new = re.sub(r'^url\s*=.*$', f'url = "custom:{url}"', block, flags=re.M)
    if 'url =' not in new:
        new = block + f'\nurl = "custom:{url}"\n'
    return new
text = re.sub(r'\[tunnel\][^\[]*', repl, text, count=1)
open(path, 'w').write(text)
print(f"patched: {path}")
PY
fi

echo
say "done. ZeroClaw will pick up the new tunnel URL on next start."
say "  state:  $STATE"
say "  log:    $LOG"
say "  stop:   zrok-share.sh --stop"

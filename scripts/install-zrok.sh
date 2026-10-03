#!/usr/bin/env bash
# install-zrok.sh — Install zrok (zrok.io) binary. Replacement for ngrok.
#
# zrok = OpenZiti overlay network. Self-hostable or use free zrok.io hosted.

set -euo pipefail

BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"

say() { printf '▸ %s\n' "$*"; }

if command -v zrok >/dev/null 2>&1 && [[ -x "$BIN_DIR/zrok" ]]; then
  say "zrok already installed: $(command -v zrok) ($(zrok version 2>&1 | tail -1))"
  exit 0
fi

arch="$(uname -m)"
case "$arch" in
  x86_64)  ZARCH="amd64" ;;
  aarch64) ZARCH="arm64" ;;
  *)       echo "unsupported arch: $arch" >&2; exit 2 ;;
esac

os="$(uname -s | tr '[:upper:]' '[:lower:]')"
[[ "$os" == "linux" || "$os" == "darwin" ]] || { echo "unsupported os: $os" >&2; exit 2; }

say "fetching latest zrok release"
LATEST="$(curl -sL https://api.github.com/repos/openziti/zrok/releases/latest | jq -r .tag_name)"
VER="${LATEST#v}"
URL="https://github.com/openziti/zrok/releases/download/${LATEST}/zrok_${VER}_${os}_${ZARCH}.tar.gz"

say "downloading: $URL"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
curl -sL "$URL" -o "$TMP/zrok.tgz"
tar xzf "$TMP/zrok.tgz" -C "$TMP"

# v2+ names the binary `zrok2`; older versions named it `zrok`
BIN="$(find "$TMP" -maxdepth 2 -type f -name 'zrok*' -executable | head -1)"
[[ -z "$BIN" ]] && BIN="$(find "$TMP" -maxdepth 2 -type f -name 'zrok*' | head -1)"
[[ -z "$BIN" ]] && { echo "no zrok binary found in archive" >&2; exit 3; }

cp "$BIN" "$BIN_DIR/zrok"
chmod +x "$BIN_DIR/zrok"

say "installed: $BIN_DIR/zrok"
"$BIN_DIR/zrok" version 2>&1 | tail -2

cat <<'EOM'

NEXT STEPS (interactive — zrok account is required):

  1. Request an invite (once per email):
       zrok invite <your-email>

  2. Check email for token, then bind this machine:
       zrok enable <invite-token>

  3. Share ZeroClaw's gateway:
       bash universal-agentic-setup/scripts/zrok-share.sh

  Self-hosting? See https://docs.zrok.io/docs/guides/self-hosting
EOM

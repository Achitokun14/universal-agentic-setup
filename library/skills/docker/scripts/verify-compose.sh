#!/usr/bin/env bash
# Verify Compose configuration. Run from the project root (the directory that contains compose.yaml).
# Usage: bash <path-to-this-skill>/scripts/verify-compose.sh [--help]
# Adapted from docker/skills docker-compose-patterns (Apache-2.0). See SOURCES.md.
set -euo pipefail

usage() {
    echo "Usage: bash <path-to-this-skill>/scripts/verify-compose.sh [--help]"
    echo "Run from the project root. Validates compose.yaml with docker compose config --quiet (no rendered configuration)."
}

if [[ "${1:-}" == "--help" && $# == 1 ]]; then
    usage
    exit 0
fi

if (( $# != 0 )); then
    usage >&2
    exit 2
fi

docker compose config --quiet

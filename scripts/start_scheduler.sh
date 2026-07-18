#!/usr/bin/env bash
# Laravel scheduler — run beside start_api.sh for AI digests / monitors
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="${HRM_API_DIR:-$HOME/Developer/hrm-nawa-api}"
PHP_BIN="${PHP_BIN:-/opt/homebrew/opt/php@8.4/bin/php}"

if [[ -d "$DEST" ]]; then
  cd "$DEST"
elif [[ -d "$ROOT/backend" ]]; then
  cd "$ROOT/backend"
else
  echo "API directory not found."
  exit 1
fi

echo "→ Scheduler (schedule:work)"
exec "$PHP_BIN" artisan schedule:work

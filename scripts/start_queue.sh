#!/usr/bin/env bash
# Process queued jobs (mail, AI tasks, leave emails) — run beside start_api.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="${HRM_API_DIR:-$HOME/Developer/hrm-nawa-api}"
PHP_BIN="${PHP_BIN:-/opt/homebrew/opt/php@8.4/bin/php}"

if [[ -d "$DEST" ]]; then
  cd "$DEST"
elif [[ -d "$ROOT/backend" ]]; then
  cd "$ROOT/backend"
else
  echo "API directory not found. Run ./scripts/start_api.sh first."
  exit 1
fi

echo "→ Queue worker ($(grep '^QUEUE_CONNECTION=' .env 2>/dev/null || echo 'QUEUE_CONNECTION=database'))"
exec "$PHP_BIN" artisan queue:work --sleep=3 --tries=3 --max-time=3600

#!/usr/bin/env bash
# Start Laravel API from a local (non-iCloud Desktop) path on :8000
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="${HRM_API_DIR:-$HOME/Developer/hrm-nawa-api}"
PHP_BIN="${PHP_BIN:-/opt/homebrew/opt/php@8.4/bin/php}"
COMPOSER_BIN="${COMPOSER_BIN:-/opt/homebrew/bin/composer}"

if [[ ! -x "$PHP_BIN" ]]; then
  PHP_BIN="$(command -v php)"
fi

mkdir -p "$(dirname "$DEST")"

echo "→ Sync backend → $DEST"
mkdir -p "$DEST"
# Prefer git archive when available (avoids iCloud Desktop hangs)
if git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  TMP="$(mktemp -d)"
  git -C "$ROOT" archive HEAD:backend | tar -x -C "$TMP"
  # Overlay latest uncommitted backend files from workspace when readable
  rsync -a --exclude 'vendor/' --exclude 'node_modules/' --exclude 'storage/logs/*' \
    "$ROOT/backend/" "$TMP/" 2>/dev/null || true
  rsync -a --delete --exclude 'vendor/' --exclude 'node_modules/' \
    --exclude 'storage/logs/*' --exclude 'database/database.sqlite' \
    "$TMP/" "$DEST/"
  rm -rf "$TMP"
else
  rsync -a --exclude 'vendor/' --exclude 'node_modules/' \
    "$ROOT/backend/" "$DEST/"
fi

cd "$DEST"
mkdir -p storage/framework/{cache,sessions,views} storage/logs bootstrap/cache database
[[ -f database/database.sqlite ]] || touch database/database.sqlite
[[ -f .env ]] || cp .env.example .env

# Force sqlite for local trial
if grep -q '^DB_CONNECTION=' .env; then
  sed -i '' 's/^DB_CONNECTION=.*/DB_CONNECTION=sqlite/' .env
else
  echo 'DB_CONNECTION=sqlite' >> .env
fi
if grep -q '^DB_DATABASE=' .env; then
  sed -i '' 's|^DB_DATABASE=.*|DB_DATABASE=database/database.sqlite|' .env
fi

if [[ ! -d vendor ]]; then
  echo "→ composer install"
  "$PHP_BIN" "$COMPOSER_BIN" install --no-interaction --prefer-dist
fi

xattr -cr "$DEST" 2>/dev/null || true

if ! grep -q '^APP_KEY=base64:' .env; then
  "$PHP_BIN" artisan key:generate --force
fi

echo "→ migrate"
"$PHP_BIN" artisan migrate --force

USER_COUNT="$("$PHP_BIN" -r "
  try {
    \$pdo = new PDO('sqlite:database/database.sqlite');
    echo (int) \$pdo->query('SELECT COUNT(*) FROM users')->fetchColumn();
  } catch (Throwable \$e) { echo 0; }
")"
if [ "${SEED_ON_START:-}" = "true" ] || [ "$USER_COUNT" = "0" ]; then
  echo "→ seed (empty DB or SEED_ON_START=true)"
  "$PHP_BIN" artisan db:seed --force
else
  echo "→ skip seed (users already exist; set SEED_ON_START=true to force)"
fi

echo "→ API + Admin on http://127.0.0.1:8000"
echo "   Admin panel: http://127.0.0.1:8000/admin"
echo "   Admin: admin@demo.com / Admin12345!"
echo "   Employee: emp01@demo.com / Employee12345!"
echo "   Optional queue worker: ./scripts/start_queue.sh"
exec "$PHP_BIN" artisan serve --host=0.0.0.0 --port=8000

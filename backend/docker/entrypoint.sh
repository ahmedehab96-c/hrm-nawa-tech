#!/bin/sh
set -e

if [ ! -f .env ]; then
  cp .env.example .env
fi

# Prefer platform-provided public URL (Render injects RENDER_EXTERNAL_URL).
if [ -z "${APP_URL:-}" ] && [ -n "${RENDER_EXTERNAL_URL:-}" ]; then
  export APP_URL="${RENDER_EXTERNAL_URL}"
fi

# Ensure a usable APP_KEY is available to the PHP process.
if [ -z "${APP_KEY:-}" ] || [ "${APP_KEY}" = "null" ] || [ "${APP_KEY}" = "base64:" ]; then
  if grep -q '^APP_KEY=base64:' .env; then
    export APP_KEY="$(grep '^APP_KEY=base64:' .env | head -n1 | cut -d= -f2-)"
  else
    export APP_KEY="base64:$(php -r 'echo base64_encode(random_bytes(32));')"
    if grep -q '^APP_KEY=' .env; then
      sed -i.bak "s|^APP_KEY=.*|APP_KEY=${APP_KEY}|" .env && rm -f .env.bak
    else
      echo "APP_KEY=${APP_KEY}" >> .env
    fi
  fi
fi

# HTTPS demos behind Render / Railway need secure cookies when APP_URL is https.
case "${APP_URL:-}" in
  https://*)
    export SESSION_SECURE_COOKIE="${SESSION_SECURE_COOKIE:-true}"
    ;;
esac

# Wait for MySQL when configured
if [ "${DB_CONNECTION:-sqlite}" = "mysql" ]; then
  echo "Waiting for MySQL at ${DB_HOST:-mysql}:${DB_PORT:-3306}..."
  i=0
  until php -r "
    try {
      new PDO(
        'mysql:host=' . getenv('DB_HOST') . ';port=' . (getenv('DB_PORT') ?: '3306') . ';dbname=' . getenv('DB_DATABASE'),
        getenv('DB_USERNAME'),
        getenv('DB_PASSWORD')
      );
      exit(0);
    } catch (Throwable \$e) {
      exit(1);
    }
  "; do
    i=$((i + 1))
    if [ "$i" -ge 60 ]; then
      echo "MySQL not ready after 60s"
      exit 1
    fi
    sleep 1
  done
fi

php artisan migrate --force --no-interaction

# Seed only on first boot (empty users) or when SEED_ON_START=true
SHOULD_SEED="${SEED_ON_START:-false}"
if [ "$SHOULD_SEED" = "true" ]; then
  php artisan db:seed --force --no-interaction
elif [ "${DB_CONNECTION:-sqlite}" = "mysql" ]; then
  COUNT="$(php -r "
    try {
      \$pdo = new PDO(
        'mysql:host=' . getenv('DB_HOST') . ';port=' . (getenv('DB_PORT') ?: '3306') . ';dbname=' . getenv('DB_DATABASE'),
        getenv('DB_USERNAME'),
        getenv('DB_PASSWORD')
      );
      \$n = (int) \$pdo->query('SELECT COUNT(*) FROM users')->fetchColumn();
      echo \$n;
    } catch (Throwable \$e) {
      echo '0';
    }
  ")"
  if [ "$COUNT" = "0" ]; then
    php artisan db:seed --force --no-interaction
  fi
elif [ -f database/database.sqlite ]; then
  COUNT="$(php -r "
    try {
      \$pdo = new PDO('sqlite:database/database.sqlite');
      \$n = (int) \$pdo->query('SELECT COUNT(*) FROM users')->fetchColumn();
      echo \$n;
    } catch (Throwable \$e) {
      echo '0';
    }
  ")"
  if [ "$COUNT" = "0" ]; then
    php artisan db:seed --force --no-interaction
  fi
else
  php artisan db:seed --force --no-interaction
fi

if [ "${RUN_QUEUE_WORKER:-false}" = "true" ] && [ "${QUEUE_CONNECTION:-sync}" != "sync" ]; then
  echo "Starting queue worker in background..."
  php artisan queue:work --sleep=3 --tries=3 --max-time=0 &
fi

PORT="${PORT:-8000}"
exec php artisan serve --host=0.0.0.0 --port="${PORT}"

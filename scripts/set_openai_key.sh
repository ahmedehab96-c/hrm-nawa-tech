#!/usr/bin/env bash
# Set OpenAI API key locally (never committed to git).
# Usage: ./scripts/set_openai_key.sh sk-your-key-here

set -euo pipefail

KEY="${1:-}"
if [[ -z "$KEY" ]]; then
  echo "Usage: ./scripts/set_openai_key.sh sk-your-openai-key"
  echo "Get a key: https://platform.openai.com/api-keys"
  exit 1
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$ROOT/backend/.env"
AI_ENV="$ROOT/.env.ai"

if [[ ! -f "$ENV_FILE" ]]; then
  cp "$ROOT/backend/.env.example" "$ENV_FILE"
  (cd "$ROOT/backend" && php artisan key:generate --force)
fi

update_var() {
  local file="$1" name="$2" value="$3"
  if grep -q "^${name}=" "$file" 2>/dev/null; then
    if [[ "$(uname)" == "Darwin" ]]; then
      sed -i '' "s|^${name}=.*|${name}=${value}|" "$file"
    else
      sed -i "s|^${name}=.*|${name}=${value}|" "$file"
    fi
  else
    echo "${name}=${value}" >> "$file"
  fi
}

update_var "$ENV_FILE" "OPENAI_API_KEY" "$KEY"
update_var "$ENV_FILE" "AI_DEFAULT_PROVIDER" "openai"

cat > "$AI_ENV" <<EOF
OPENAI_API_KEY=$KEY
AI_DEFAULT_PROVIDER=openai
OPENAI_MODEL=gpt-4o-mini
EOF

(cd "$ROOT/backend" && php artisan config:clear)

echo "✅ OpenAI key saved to backend/.env and .env.ai (gitignored)"
echo "Restart API: cd backend && php artisan serve"

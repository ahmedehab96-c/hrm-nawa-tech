#!/usr/bin/env bash
# Configure Gemini locally without exposing the key in shell history.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$ROOT/backend/.env"
AI_ENV="$ROOT/.env.ai"
MODEL="${GEMINI_MODEL:-gemini-3.5-flash}"

if [[ ! -f "$ENV_FILE" ]]; then
  cp "$ROOT/backend/.env.example" "$ENV_FILE"
  (cd "$ROOT/backend" && php artisan key:generate --force)
fi

read -r -s -p "Gemini API key: " KEY
echo
if [[ -z "$KEY" ]]; then
  echo "Gemini API key cannot be empty."
  exit 1
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
    printf '%s=%s\n' "$name" "$value" >> "$file"
  fi
}

touch "$AI_ENV"
chmod 600 "$AI_ENV"

for file in "$ENV_FILE" "$AI_ENV"; do
  update_var "$file" "AI_DEFAULT_PROVIDER" "gemini"
  update_var "$file" "GEMINI_API_KEY" "$KEY"
  update_var "$file" "GEMINI_MODEL" "$MODEL"
done

(cd "$ROOT/backend" && php artisan config:clear)

echo "Gemini configured securely (model: $MODEL)."
echo "Next: choose Gemini in Admin > Company Settings, then restart the API/queue."

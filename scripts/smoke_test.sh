#!/usr/bin/env bash
# Smoke test — API health + admin redirect (run after start_api.sh or docker compose up)
set -euo pipefail

BASE="${SMOKE_BASE_URL:-http://127.0.0.1:8000}"

echo "→ GET $BASE/api/health"
HEALTH="$(curl -fsS "$BASE/api/health")"
echo "$HEALTH" | grep -q '"status":"ok"' || {
  echo "Health check failed: $HEALTH"
  exit 1
}

echo "→ GET $BASE/up"
curl -fsS -o /dev/null "$BASE/up"

echo "→ GET $BASE/admin (expect redirect or 200)"
CODE="$(curl -s -o /dev/null -w '%{http_code}' "$BASE/admin")"
if [[ "$CODE" != "200" && "$CODE" != "302" ]]; then
  echo "Admin route unexpected status: $CODE"
  exit 1
fi

echo "✓ Smoke tests passed"

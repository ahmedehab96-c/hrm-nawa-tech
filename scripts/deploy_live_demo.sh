#!/usr/bin/env bash
# Interactive Railway deploy helper for the portfolio live demo.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if ! command -v railway >/dev/null 2>&1; then
  echo "Install Railway CLI first: brew install railway"
  exit 1
fi

echo "→ Checking Railway login..."
if ! railway whoami >/dev/null 2>&1; then
  echo "Browser login required..."
  railway login
fi

echo "→ Logged in as: $(railway whoami)"
echo
echo "Next steps (run one by one if needed):"
echo "  1) railway init"
echo "  2) railway add   # choose PostgreSQL"
echo "  3) Set APP_KEY, APP_URL, APP_ENV=production, SEED_ON_START=true"
echo "  4) railway up"
echo "  5) railway domain"
echo
echo "Full guide: docs/LIVE_DEMO.md"
echo
read -r -p "Open Railway login / dashboard now? [y/N] " ans
if [[ "${ans:-}" =~ ^[Yy]$ ]]; then
  railway login || true
  open 'https://railway.app/dashboard' 2>/dev/null || true
fi

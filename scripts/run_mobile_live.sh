#!/usr/bin/env bash
# Run the employee Flutter app against the public Render demo API.
# Usage:
#   ./scripts/run_mobile_live.sh              # auto-pick device
#   ./scripts/run_mobile_live.sh "iPhone 16 Pro"
#   ./scripts/run_mobile_live.sh chrome
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

API_URL="${API_BASE_URL:-https://hrm-nawa-api.onrender.com/api}"
DEVICE_ARG=()
if [[ $# -gt 0 ]]; then
  DEVICE_ARG=(-d "$1")
fi

echo "→ Employee app → live API"
echo "   API:   $API_URL"
echo "   Login: emp01@demo.com / Employee12345!"
echo "   Tip:   first open may take ~30s if Render was idle"

flutter pub get
exec flutter run "${DEVICE_ARG[@]}" \
  --dart-define=USE_LIVE_DEMO=true \
  --dart-define=API_BASE_URL="$API_URL"

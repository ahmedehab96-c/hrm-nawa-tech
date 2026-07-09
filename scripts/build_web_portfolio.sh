#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

flutter pub get
flutter build web --release --dart-define=API_BASE_URL=/api

echo ""
echo "Web build ready: build/web"
echo "Start full stack: docker compose up --build"
echo "Open: http://localhost:8080/welcome"

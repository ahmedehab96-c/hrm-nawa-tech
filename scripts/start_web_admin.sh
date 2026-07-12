#!/usr/bin/env bash
# Start Flutter web admin against local Laravel API (:8000)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

export COPYFILE_DISABLE=1
export COPY_EXTENDED_ATTRIBUTES_DISABLE=1

flutter pub get
echo "→ Web admin on http://localhost:3000"
echo "   Login: admin@demo.com / Admin12345!"
echo "   API:   http://127.0.0.1:8000/api (auto in debug)"
exec flutter run -d chrome --web-port=3000

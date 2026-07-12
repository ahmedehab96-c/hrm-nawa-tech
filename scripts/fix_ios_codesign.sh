#!/usr/bin/env bash
# Fix iOS CodeSign "resource fork / detritus" errors on Desktop paths.
# Usage: ./scripts/fix_ios_codesign.sh

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENGINE="${FLUTTER_ROOT:-/opt/homebrew/share/flutter}/bin/cache/artifacts/engine"

echo "→ Clearing extended attributes (xattr)..."
xattr -cr "$ROOT/ios" 2>/dev/null || true
xattr -cr "$ROOT/build" 2>/dev/null || true
xattr -cr "$ENGINE" 2>/dev/null || true

echo "→ flutter clean + pub get"
cd "$ROOT"
flutter clean
flutter pub get
flutter gen-l10n

echo "→ pod install"
cd ios && pod install && cd ..

echo "✅ Done. Now run:"
echo "   flutter run -d \"iPhone 16 Pro\""
echo ""
echo "If it still fails, move the project off Desktop (no spaces in path):"
echo "   mkdir -p ~/Developer"
echo "   mv \"$ROOT\" ~/Developer/hrm-nawa-tech"
echo "   cd ~/Developer/hrm-nawa-tech && flutter run"

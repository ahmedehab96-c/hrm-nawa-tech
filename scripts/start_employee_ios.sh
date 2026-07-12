#!/usr/bin/env bash
# Start employee iOS app from a local path (avoids Desktop codesign / iCloud issues)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="${HRM_APP_DIR:-$HOME/Developer/hrm-nawa-tech}"
DEVICE="${1:-iPhone 16 Pro}"

mkdir -p "$(dirname "$DEST")"

echo "→ Sync Flutter app → $DEST"
if [[ ! -d "$DEST/.git" ]]; then
  if git -C "$ROOT" remote get-url origin >/dev/null 2>&1; then
    git clone --depth 1 "$(git -C "$ROOT" remote get-url origin)" "$DEST" || true
  fi
  mkdir -p "$DEST"
fi

rsync -a --delete \
  --exclude '.dart_tool/' \
  --exclude 'build/' \
  --exclude 'ios/Pods/' \
  --exclude 'ios/.symlinks/' \
  --exclude 'backend/' \
  --exclude '.git/' \
  "$ROOT/" "$DEST/"

# Ensure no flutter gen-l10n (we use AppStrings)
rm -f "$DEST/l10n.yaml"
perl -i -pe 's/generate:\s*true/generate: false/' "$DEST/pubspec.yaml" 2>/dev/null || true
xattr -cr "$DEST" 2>/dev/null || true

cd "$DEST"
export COPYFILE_DISABLE=1
export COPY_EXTENDED_ATTRIBUTES_DISABLE=1

flutter pub get
(cd ios && pod install >/dev/null)

xcrun simctl boot "$DEVICE" 2>/dev/null || true
open -a Simulator

echo "→ Employee app on $DEVICE"
echo "   Login: emp01@demo.com / Employee12345!"
echo "   API:   http://127.0.0.1:8000/api (auto in debug iOS sim)"
exec flutter run -d "$DEVICE"

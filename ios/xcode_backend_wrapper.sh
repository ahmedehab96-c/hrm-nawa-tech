#!/bin/sh
# Wrapper for Flutter's xcode_backend.sh.
# Desktop/iCloud paths can leave com.apple.provenance xattrs that break CodeSign.
# Flutter only strips com.apple.FinderInfo; we clear all attrs and retry once.

set -e

FLUTTER_BACKEND="$FLUTTER_ROOT/packages/flutter_tools/bin/xcode_backend.sh"
APP_ROOT="${FLUTTER_APPLICATION_PATH:-$(cd "$(dirname "$0")/.." && pwd)}"

strip_metadata() {
  xattr -cr "$FLUTTER_ROOT/bin/cache/artifacts/engine" 2>/dev/null || true
  xattr -cr "$APP_ROOT/build/ios" 2>/dev/null || true
  xattr -cr "/tmp/hrm-nawa-tech-build/ios" 2>/dev/null || true
}

if [ "$1" = "build" ]; then
  strip_metadata
  if /bin/sh "$FLUTTER_BACKEND" build; then
    exit 0
  fi
  strip_metadata
  exec /bin/sh "$FLUTTER_BACKEND" build
fi

if [ "$1" = "embed_and_thin" ]; then
  strip_metadata
  exec /bin/sh "$FLUTTER_BACKEND" embed_and_thin
fi

exec /bin/sh "$FLUTTER_BACKEND" "$@"

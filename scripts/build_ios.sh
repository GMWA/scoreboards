#!/usr/bin/env bash
# Build a release iOS app. Requires macOS + Xcode.
# Usage: ./scripts/build_ios.sh [extra flutter build args]
#   Unsigned build (e.g. for CI):     ./scripts/build_ios.sh --no-codesign

set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

if [ "$(uname)" != "Darwin" ]; then
  echo "error: iOS builds require macOS + Xcode." >&2
  exit 1
fi

# Release builds read .env.production (production URLs); .env must also
# exist because both files are bundled as assets.
for f in .env .env.production; do
  if [ ! -f "$f" ]; then
    echo "error: $f not found at repo root (see .env.example)." >&2
    exit 1
  fi
done

flutter pub get
flutter build ios --release \
  --obfuscate --split-debug-info=build/symbols/ios "$@"

echo
echo "Build output: build/ios/iphoneos/Runner.app"
echo "Keep build/symbols/ios for this version: it's needed to read crash stack traces."

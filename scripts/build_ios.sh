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

if [ ! -f .env ]; then
  echo "error: .env not found at repo root. Copy .env.example to .env and fill in real values before building a release." >&2
  exit 1
fi

flutter pub get
flutter build ios --release "$@"

echo
echo "Build output: build/ios/iphoneos/Runner.app"

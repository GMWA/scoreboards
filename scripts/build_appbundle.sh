#!/usr/bin/env bash
# Build a release App Bundle (.aab) for Play Store submission, with
# obfuscated Dart code. The Play Store splits it per device automatically.
# Usage: ./scripts/build_appbundle.sh [extra flutter build args]

set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

if [ ! -f .env ]; then
  echo "error: .env not found at repo root. Copy .env.example to .env and fill in real values before building a release." >&2
  exit 1
fi

if [ ! -f android/key.properties ]; then
  echo "error: android/key.properties not found. Play Store bundles must be signed with your upload key; see android/key.properties.example." >&2
  exit 1
fi

flutter pub get
flutter build appbundle --release \
  --obfuscate --split-debug-info=build/symbols/android "$@"

echo
echo "App Bundle: build/app/outputs/bundle/release/app-release.aab"
echo "Keep build/symbols/android for this version: it's needed to read crash stack traces."

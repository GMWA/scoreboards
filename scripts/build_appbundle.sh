#!/usr/bin/env bash
# Build a release App Bundle (.aab) for Play Store submission, with
# obfuscated Dart code. The Play Store splits it per device automatically.
# Usage: ./scripts/build_appbundle.sh [extra flutter build args]

set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

# Release builds read .env.production (production URLs); .env must also
# exist because both files are bundled as assets.
for f in .env .env.production; do
  if [ ! -f "$f" ]; then
    echo "error: $f not found at repo root (see .env.example)." >&2
    exit 1
  fi
done

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

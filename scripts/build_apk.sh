#!/usr/bin/env bash
# Build release APKs, one per CPU architecture (~20 MB each instead of one
# ~60 MB APK containing all three), with obfuscated Dart code.
# Usage: ./scripts/build_apk.sh [extra flutter build args]

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
  echo "warning: android/key.properties not found; these APKs are signed with the debug key (fine for testing, not for distribution)." >&2
fi

flutter pub get
flutter build apk --release --split-per-abi \
  --obfuscate --split-debug-info=build/symbols/android "$@"

echo
echo "APKs (install the one matching the device; most phones are arm64-v8a):"
ls -1 build/app/outputs/flutter-apk/app-*-release.apk
echo
echo "Keep build/symbols/android for this version: it's needed to read crash stack traces."

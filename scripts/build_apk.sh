#!/usr/bin/env bash
# Build release APKs, one per CPU architecture (~20 MB each instead of one
# ~60 MB APK containing all three), with obfuscated Dart code.
# Usage: ./scripts/build_apk.sh [extra flutter build args]

set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

if [ ! -f .env ]; then
  echo "error: .env not found at repo root. Copy .env.example to .env and fill in real values before building a release." >&2
  exit 1
fi

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

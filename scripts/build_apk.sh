#!/usr/bin/env bash
# Build a release APK.
# Usage: ./scripts/build_apk.sh [extra flutter build args]

set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

if [ ! -f .env ]; then
  echo "error: .env not found at repo root. Copy .env.example to .env and fill in real values before building a release." >&2
  exit 1
fi

flutter pub get
flutter build apk --release "$@"

echo
echo "APK: build/app/outputs/flutter-apk/app-release.apk"

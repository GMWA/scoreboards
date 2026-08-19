#!/usr/bin/env bash
# Build a release App Bundle (.aab) for Play Store submission.
# Usage: ./scripts/build_appbundle.sh [extra flutter build args]

set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

if [ ! -f .env ]; then
  echo "error: .env not found at repo root. Copy .env.example to .env and fill in real values before building a release." >&2
  exit 1
fi

flutter pub get
flutter build appbundle --release "$@"

echo
echo "App Bundle: build/app/outputs/bundle/release/app-release.aab"

#!/usr/bin/env bash
# One-time setup: point git at the repo's tracked hooks directory.
# Run this once after cloning: ./scripts/setup-hooks.sh

set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"

git -C "$repo_root" config core.hooksPath .githooks
chmod +x "$repo_root"/.githooks/*

echo "Git hooks enabled (core.hooksPath = .githooks)."

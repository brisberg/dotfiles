#!/bin/sh
# Point this repository at its tracked hooks directory.
#
# Idempotent. Safe to run repeatedly and from anywhere.

set -eu

repo_root=$(cd "$(dirname "$0")/.." && pwd)
cd "$repo_root"

git config core.hooksPath githooks
echo "core.hooksPath -> githooks"

patterns="${DOTFILES_FORBIDDEN_PATTERNS:-$HOME/.config/dotfiles/forbidden-patterns}"
if [ -f "$patterns" ]; then
  echo "leak-check: pattern list present, check is active"
else
  echo "leak-check: no pattern list at that path, check will no-op until one exists"
fi

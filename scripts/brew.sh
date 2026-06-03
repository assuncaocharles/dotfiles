#!/usr/bin/env bash
# Install Homebrew (if missing) and everything in the Brewfile.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v brew >/dev/null 2>&1; then
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Load brew into this shell (Apple Silicon path).
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "==> Homebrew already installed."
fi

echo "==> Running brew bundle..."
brew bundle --file="$DOTFILES_DIR/Brewfile"

echo "==> Homebrew setup complete."

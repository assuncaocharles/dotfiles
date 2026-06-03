#!/usr/bin/env bash
# Add asdf plugins and install the runtimes pinned in home/.tool-versions.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v asdf >/dev/null 2>&1; then
  # asdf is installed via Homebrew; source it for this shell if available.
  if [ -f /opt/homebrew/opt/asdf/libexec/asdf.sh ]; then
    . /opt/homebrew/opt/asdf/libexec/asdf.sh
  else
    echo "asdf not found. Run scripts/brew.sh first." >&2
    exit 1
  fi
fi

echo "==> Adding asdf plugins..."
for plugin in nodejs ruby erlang elixir; do
  if ! asdf plugin list 2>/dev/null | grep -qx "$plugin"; then
    asdf plugin add "$plugin"
  else
    echo "    $plugin plugin already added."
  fi
done

echo "==> Installing runtimes from .tool-versions..."
# `asdf install` with no args reads the .tool-versions in the current dir.
( cd "$DOTFILES_DIR/home" && asdf install )

echo "==> asdf setup complete."

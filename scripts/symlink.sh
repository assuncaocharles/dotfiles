#!/usr/bin/env bash
# Symlink every file in home/ into $HOME.
# Existing real files are backed up to <file>.backup before linking.
# Idempotent: an already-correct symlink is left untouched.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOME_DIR="$DOTFILES_DIR/home"

echo "==> Symlinking dotfiles into $HOME..."
# Include dotfiles (the glob below uses .* via find to catch hidden files).
find "$HOME_DIR" -maxdepth 1 -type f | while read -r src; do
  name="$(basename "$src")"
  dest="$HOME/$name"

  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    echo "    $name already linked."
    continue
  fi

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    echo "    backing up existing $name -> $name.backup"
    mv "$dest" "$dest.backup"
  fi

  ln -sf "$src" "$dest"
  echo "    linked $name"
done

echo "==> Symlinks complete."

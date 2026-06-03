#!/usr/bin/env bash
# Dotfiles installer — run on a fresh Mac to set up the full environment.
# Each step is idempotent and safe to re-run.
#
#   git clone https://github.com/assuncaocharles/dotfiles.git ~/Projects/dotfiles
#   cd ~/Projects/dotfiles && ./install.sh
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

echo "============================================"
echo "  Dotfiles install — $DOTFILES_DIR"
echo "============================================"

###############################################################################
# 1. Xcode Command Line Tools                                                 #
###############################################################################
if ! xcode-select -p >/dev/null 2>&1; then
  echo "==> Installing Xcode Command Line Tools..."
  xcode-select --install || true
  echo "    Finish the GUI installer, then re-run ./install.sh"
  exit 0
else
  echo "==> Xcode Command Line Tools already installed."
fi

###############################################################################
# 2. Homebrew + Brewfile                                                      #
###############################################################################
bash "$DOTFILES_DIR/scripts/brew.sh"

# Make sure brew is on PATH for the rest of this run.
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

###############################################################################
# 3. Oh My Zsh + theme + plugins                                             #
###############################################################################
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "==> Installing Oh My Zsh..."
  RUNZSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "==> Oh My Zsh already installed."
fi

# powerlevel10k as a custom theme (brew also installs it, but omz expects this path).
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
  echo "==> Cloning powerlevel10k theme..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
else
  echo "==> powerlevel10k theme already present."
fi

###############################################################################
# 4. asdf runtimes                                                            #
###############################################################################
bash "$DOTFILES_DIR/scripts/asdf.sh"

###############################################################################
# 5. Global npm packages                                                      #
###############################################################################
# Source asdf so node/npm are available in this shell.
if [ -f /opt/homebrew/opt/asdf/libexec/asdf.sh ]; then
  . /opt/homebrew/opt/asdf/libexec/asdf.sh
fi
bash "$DOTFILES_DIR/scripts/npm.sh"

###############################################################################
# 6. colorls (Ruby gem — powers the ls/ll/lc aliases)                         #
###############################################################################
if ! command -v colorls >/dev/null 2>&1; then
  echo "==> Installing colorls gem..."
  gem install colorls || echo "    colorls install failed (non-fatal) — install manually if you want the ls aliases."
else
  echo "==> colorls already installed."
fi

###############################################################################
# 7. Symlink dotfiles                                                         #
###############################################################################
bash "$DOTFILES_DIR/scripts/symlink.sh"

###############################################################################
# 8. macOS system defaults                                                    #
###############################################################################
read -r -p "==> Apply macOS system defaults now? [y/N] " reply
if [[ "$reply" =~ ^[Yy]$ ]]; then
  bash "$DOTFILES_DIR/macos.sh"
else
  echo "    Skipped. Run ./macos.sh later if you want them."
fi

###############################################################################
# 9. Manual TODO                                                              #
###############################################################################
cat <<'EOF'

============================================
  Done! Remaining manual steps:
============================================
  [ ] Install from the App Store: Xcode, and any other store-only apps
  [ ] Generate an SSH key and add it to GitHub:
        ssh-keygen -t ed25519 -C "junioassuncaocharles@gmail.com"
        pbcopy < ~/.ssh/id_ed25519.pub   # then paste into GitHub > Settings > SSH keys
  [ ] Sign in to apps: Chrome, Slack, Notion, Spotify, 1Password, etc.
  [ ] Set up any required env vars / tokens (NPM_TOKEN, etc.) — not stored in this repo
  [ ] Run `p10k configure` if you want to re-tune the prompt
  [ ] Restart (or log out/in) so all macOS defaults take effect

  Open a new terminal to load the new .zshrc.
EOF

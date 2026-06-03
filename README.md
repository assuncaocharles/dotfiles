# dotfiles

One script to take a fresh Mac (Apple Silicon) to a fully configured dev
machine: CLI tools, GUI apps, shell config, language runtimes, and sensible
macOS system preferences.

> No secrets live in this repo. API tokens and machine-specific credentials are
> intentionally left out — set them up by hand after install.

## Bootstrap

```sh
git clone https://github.com/assuncaocharles/dotfiles.git ~/Projects/dotfiles
cd ~/Projects/dotfiles
./install.sh
```

Re-running `./install.sh` is safe — every step is idempotent.

## What it does

`install.sh` runs these steps in order:

1. **Xcode Command Line Tools** — `xcode-select --install`
2. **Homebrew + `Brewfile`** — all CLI tools and GUI apps (`brew bundle`)
3. **Oh My Zsh** + **powerlevel10k** theme + **zsh-syntax-highlighting**
4. **asdf** runtimes pinned in `home/.tool-versions` (node, ruby, erlang, elixir)
5. **Global npm packages** (`scripts/npm.sh`)
6. **colorls** gem (powers the `ls`/`ll`/`lc` aliases)
7. **Symlinks** every file in `home/` into `$HOME` (existing files backed up to
   `*.backup`)
8. **macOS defaults** (`macos.sh`) — optional, prompted

## Layout

| Path | Purpose |
|------|---------|
| `install.sh` | Entry point — orchestrates everything |
| `Brewfile` | Taps, formulae, casks for `brew bundle` |
| `macos.sh` | `defaults write` system preferences |
| `home/` | Dotfiles symlinked into `$HOME` (`.zshrc`, `.p10k.zsh`, `.gitconfig`, `.gitignore_global`, `.tool-versions`) |
| `scripts/` | `brew.sh`, `asdf.sh`, `npm.sh`, `symlink.sh` |

## What's installed

- **Core CLI:** asdf, awscli, coreutils, curl, direnv, fzf, gh, git, gnupg,
  lazygit, libpq, pipx, powerlevel10k, zsh-syntax-highlighting
- **Build:** cmake, pkgconf, zlib
- **Media:** ffmpeg, imagemagick, potrace
- **Mobile/Java:** cocoapods, openjdk@17, temurin, android-commandlinetools
- **Cloud:** cloudflared, supabase
- **AI CLI:** opencode
- **Apps:** Cursor, VS Code, Warp, Google Chrome, Docker, Slack, Notion,
  Obsidian, Spotify, Telegram, WhatsApp, Zoom, Tiles
- **Runtimes (asdf):** node 22.14.0, ruby 2.7.6, erlang 28.3, elixir 1.19.5-otp-28
- **npm globals:** pnpm, corepack, @railway/cli, auth0-deploy-cli, eas-cli,
  http-server

## Terminal (Warp)

Warp is installed by the Brewfile but **not** configured — its settings live in
an internal database, not a versionable dotfile, so you set it up in the GUI:

- Warp runs your `.zshrc`, so aliases, PATH, and tools work out of the box.
- To use the powerlevel10k prompt instead of Warp's built-in one:
  **Settings → Appearance → Prompt → "Honor the shell's custom prompt (PS1)"**.
- Theme, font, and keybindings are configured per-machine in Warp's settings.

## Manual steps after install

- Install Xcode and other App Store–only apps
- Generate an SSH key and add it to GitHub
- Sign in to apps (Chrome, Slack, Notion, etc.)
- Set up env vars / tokens (e.g. `NPM_TOKEN`) — not stored here
- Restart or log out/in so all macOS defaults take effect

# Dotfiles — Design Spec

**Date:** 2026-06-03
**Status:** Approved (pending spec review)

## Goal

Run one script on a fresh Mac and end up with a fully configured machine — CLI
tools, GUI apps, shell config, runtimes, and system preferences — matching the
current setup, with **all secrets and Appcues-specific config removed**.

Reference: `github.com/assuncaocharles/dotfiles` (the older `.macos` approach),
modernized into a Brewfile + modular installer.

## Non-Goals

- No secret/env mechanism. Secrets are stripped entirely; env vars are set up
  manually on each machine (user's explicit choice).
- No automated tests. This is a shell setup script; verification is idempotency
  plus a manual run.
- No GNU `stow` dependency. Plain `ln -sf` symlinking.

## Repo Structure

```
dotfiles/
├── README.md            # what it does + one-line bootstrap command
├── install.sh           # entry point — orchestrates everything, idempotent
├── Brewfile             # taps, formulae, casks (brew bundle)
├── macos.sh             # `defaults write` system prefs (adapted from old .macos)
├── home/                # files symlinked into $HOME
│   ├── .zshrc           # cleaned (no secrets, no Appcues, bugs fixed)
│   ├── .p10k.zsh        # existing powerlevel10k prompt config
│   ├── .gitconfig       # cleaned (no token, no insteadOf rewrite)
│   ├── .gitignore_global
│   └── .tool-versions   # asdf runtimes
└── scripts/
    ├── brew.sh          # install Homebrew + `brew bundle`
    ├── asdf.sh          # asdf plugins + install runtimes from .tool-versions
    ├── npm.sh           # global npm packages
    └── symlink.sh       # ln -sf each home/ file into $HOME (backs up existing)
```

## install.sh Flow

Each step must be **idempotent** (safe to re-run). Order:

1. **Xcode Command Line Tools** — `xcode-select --install` (skip if present)
2. **Homebrew** — install if missing, then `brew bundle --file=Brewfile`
3. **Oh My Zsh** — unattended install; add powerlevel10k + zsh-syntax-highlighting
4. **asdf** — add plugins (nodejs, ruby, erlang, elixir), `asdf install` from
   `.tool-versions`
5. **Global npm packages** — via `scripts/npm.sh`
6. **colorls gem** — `gem install colorls` (the `ls`/`ll`/`lc` aliases need it)
7. **Symlink dotfiles** — `home/*` into `$HOME`; back up any existing real file
   to `<file>.backup` before linking
8. **macOS defaults** — run `macos.sh`
9. **Manual TODO** — print remaining manual steps (App Store apps incl. Xcode,
   generate SSH key + add to GitHub, app sign-ins, set env vars/tokens)

## Brewfile Contents

**Taps:** `homebrew/cask` (implicit), plus any taps for kept formulae.

**Formulae (core):**
`asdf` `awscli` `direnv` `fzf` `gh` `git` `gnupg` `lazygit` `libpq` `pipx`
`powerlevel10k` `zsh-syntax-highlighting` `coreutils` `curl` `cmake` `pkgconf`
`zlib`

**Formulae (optional groups — kept per user, prune if desired):**
- Android/mobile: `cocoapods`, `openjdk@17` (+ casks `temurin`, `temurin@17`,
  `android-commandlinetools`)
- Media: `ffmpeg` `imagemagick` `potrace`
- AI CLI: `anomalyco/tap/opencode`
- Cloud: `supabase/tap/supabase` `cloudflared`

**Dropped (Appcues / leftover):** `saml2aws`, `bastionzero/tap/zli`, `circleci`,
`openssl@1.1` (deprecated leftover), `ffmpeg-full` (redundant with `ffmpeg`).

**Casks:** `cursor` `google-chrome` `docker` `notion` `obsidian` `slack`
`spotify` `telegram` `warp` `whatsapp` `visual-studio-code` `zoom` `tiles`
(+ Android casks above if kept).

## Global npm packages (scripts/npm.sh)

Keep: `pnpm` `@railway/cli` `auth0-deploy-cli` `eas-cli` `http-server`
`corepack`.
Skip (local symlinks / project-specific): `@maestrio/sdk`, `qaengineer-cli`,
`qaengineer-monorepo`, `eslint-plugin-exceptions`.

## asdf runtimes (.tool-versions)

```
nodejs 22.14.0
ruby 2.7.6
erlang 28.3
elixir 1.19.5-otp-28
```

## Cleaned .zshrc

**Removed:**
- Entire AppCues section: `NPM_TOKEN`, `FONT_AWESOME_TOKEN`,
  `CIRCLE_API_USER_TOKEN`, `HEX_API_KEY`, `OBAN_KEY_FINGERPRINT`,
  `OBAN_LICENSE_KEY`, all `tunnel_*` aliases, `ensure_aws_credentials`/`apm`
  functions, `studio:prod|staging|test` aliases, the commented `opscues()` block.
- RVM lines (`source .../rvm`, `$HOME/.rvm/bin` PATH) — asdf manages Ruby.

**Fixed:**
- `Function` → lowercase (moot — the functions are removed).
- Curly/smart quotes in `clean:branch` alias → straight quotes, working version.
- The `bun` / `BUN_INSTALL` block is duplicated 3× → collapse to one.
- Duplicate `source ~/.p10k.zsh` lines → one.

**Kept:**
- p10k instant prompt, `ZSH`/`BREW`/PATH exports, `ZSH_THEME`.
- All git aliases (`gs ga gp gc gcz gpl gb gck gckn gw`), `cls`, docker aliases
  (`docc doci`), colorls aliases (`ll ls lc`), `clean:branch`.
- Keybindings (word nav, line start/end).
- `direnv hook`, `ANDROID_HOME` exports (kept with Android group),
  fzf, asdf, zsh-syntax-highlighting, libpq PATH, bun, `claude-mem` alias.

## Cleaned .gitconfig

Keep `[user]`, `[init] defaultBranch = master`, `[core] excludesfile`.
**Remove** the `[url "https://x-access-token:ghs_...@github.com/"] insteadOf`
block (embedded GitHub token).

## Symlink Strategy (scripts/symlink.sh)

For each file in `home/`: if `$HOME/<file>` exists and is not already the
correct symlink, move it to `$HOME/<file>.backup`, then `ln -sf` the repo file
into `$HOME`. Idempotent — re-running relinks without re-backing-up an existing
correct symlink.

## README.md

- One-paragraph description.
- Bootstrap: clone to `~/Projects/dotfiles`, `cd`, `./install.sh`.
- Section listing what gets installed/configured.
- Manual post-install TODO checklist (matches step 9).
- Note: secrets are intentionally not included; set env vars manually.

## Verification

- `install.sh` and every `scripts/*.sh` re-run cleanly (idempotent) with no
  errors on an already-configured machine.
- `shellcheck` passes on all scripts (if available).
- Symlinks resolve to repo files; `.zshrc` sources without error in a new shell.

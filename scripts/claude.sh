#!/usr/bin/env bash
# Install Claude Code, restore global config + plugins, and reinstall skills
# from gstack and the `skills` CLI (~/.agents). Idempotent.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_DIR="$HOME/.claude"

###############################################################################
# 1. Claude Code binary (official native installer)                           #
###############################################################################
if ! command -v claude >/dev/null 2>&1 && [ ! -x "$HOME/.local/bin/claude" ]; then
  echo "==> Installing Claude Code..."
  curl -fsSL https://claude.ai/install.sh | bash
else
  echo "==> Claude Code already installed."
fi

###############################################################################
# 2. Global config (CLAUDE.md, settings) — plugins auto-restore from these    #
###############################################################################
mkdir -p "$CLAUDE_DIR"
for f in CLAUDE.md settings.json settings.local.json; do
  src="$DOTFILES_DIR/claude/$f"
  dest="$CLAUDE_DIR/$f"
  [ -f "$src" ] || continue
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    echo "    ~/.claude/$f already linked."
    continue
  fi
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    echo "    backing up existing ~/.claude/$f -> $f.backup"
    mv "$dest" "$dest.backup"
  fi
  ln -sf "$src" "$dest"
  echo "    linked ~/.claude/$f"
done
echo "    Enabled plugins (superpowers, code-review, posthog, railway, claude-mem,"
echo "    warp, github, frontend-design, code-simplifier, swift-lsp, security-guidance)"
echo "    re-clone from their marketplaces on next \`claude\` launch."

###############################################################################
# 3. gstack skills (browse, ship, office-hours, cso, qa, ...)                 #
###############################################################################
if [ ! -d "$CLAUDE_DIR/skills/gstack" ]; then
  echo "==> Installing gstack..."
  git clone --single-branch --depth 1 https://github.com/garrytan/gstack.git \
    "$CLAUDE_DIR/skills/gstack"
  ( cd "$CLAUDE_DIR/skills/gstack" && ./setup )
else
  echo "==> gstack already installed."
fi

###############################################################################
# 4. Agent skills via the `skills` CLI (~/.agents)                            #
#    Exact subset captured in claude/agents-skill-lock.json.                  #
###############################################################################
# Record the lock file for reference.
mkdir -p "$HOME/.agents"
cp "$DOTFILES_DIR/claude/agents-skill-lock.json" "$HOME/.agents/.skill-lock.json"

echo "==> Restoring agent skills via the 'skills' CLI..."

skills_add() {
  local source="$1" skill_list="$2"
  echo "    + $source"
  npx -y skills add "$source" \
    --skill "$skill_list" --agent claude-code --global --yes \
    || echo "      (failed for $source — install manually with: npx skills add $source)"
}

skills_add "auth0/agent-skills" \
  "auth0-mfa,auth0-migration,auth0-quickstart,auth0-android,auth0-angular,auth0-aspnetcore-api,auth0-expo,auth0-express,auth0-fastapi-api,auth0-fastify,auth0-fastify-api,auth0-flask,auth0-nextjs,auth0-nuxt,auth0-react,auth0-react-native,auth0-spa-js,auth0-swift,auth0-vue,express-oauth2-jwt-bearer"

skills_add "heygen-com/hyperframes" \
  "animejs,css-animations,hyperframes,hyperframes-cli,hyperframes-registry,gsap,lottie,remotion-to-hyperframes,tailwind,three,waapi,website-to-hyperframes"

skills_add "remotion-dev/skills" "remotion-best-practices"

skills_add "vercel-labs/skills" "find-skills"

echo "==> Claude Code setup complete. Run \`claude\` once to finish plugin restore."

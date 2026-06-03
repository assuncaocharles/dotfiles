#!/usr/bin/env bash
# Install global npm packages. Requires nodejs (via asdf) on PATH.
set -euo pipefail

if ! command -v npm >/dev/null 2>&1; then
  echo "npm not found. Run scripts/asdf.sh first (installs nodejs)." >&2
  exit 1
fi

PACKAGES=(
  pnpm
  corepack
  @railway/cli
  auth0-deploy-cli
  eas-cli
  http-server
)

echo "==> Installing global npm packages..."
npm install -g "${PACKAGES[@]}"

echo "==> Global npm packages installed."

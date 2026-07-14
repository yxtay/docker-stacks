#!/usr/bin/env bash
set -euo pipefail

PORTAINER_DATA=${PORTAINER_DATA:-/apps/portainer}
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/portainer"

# Check remote HEAD without fetching objects
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git ls-remote origin HEAD | cut -f1)

if [ "${LOCAL}" == "${REMOTE}" ]; then
  exit 0
fi

# Fetch and reset to latest
echo "Updating: ${LOCAL} -> ${REMOTE}"
git fetch origin
git reset --hard "${REMOTE}"

# Generate .env if missing
if [ ! -f .env ]; then
  key=$(openssl rand -hex 32)
  echo "ENCRYPTION_KEY=${key}" >>.env
  echo "JWT_SECRET=${key}" >>.env
fi

cat .env
docker compose up --detach --pull always --remove-orphans

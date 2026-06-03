#!/usr/bin/env bash
set -euo pipefail

PORTAINER_DATA=${PORTAINER_DATA:-/apps/portainer}
cd "$(git -C "$(dirname "${0}")" rev-parse --show-toplevel)/portainer"

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
  TZ=$(timedatectl show -p Timezone --value 2>/dev/null ||
    cat /etc/timezone 2>/dev/null ||
    readlink /etc/localtime | sed 's|.*/zoneinfo/||' ||
    echo "UTC")
  cat >.env <<EOF
PUID=$(id -u)
PGID=$(id -g)
TZ=${TZ}
PORTAINER_DATA=${PORTAINER_DATA}
EOF
fi

cat .env
docker compose up --detach --pull always --remove-orphans
docker image prune --force
docker network prune --force

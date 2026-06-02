#!/usr/bin/env bash
set -euo pipefail

REPO_DIR=$(cd "$(dirname "${0}")/.." && pwd)
STACK_DATA=/data/portainer
STACK_DIR=${REPO_DIR}/portainer

# Pull and reset to latest if remote has changes
git -C "${REPO_DIR}" fetch origin main
LOCAL=$(git -C "${REPO_DIR}" rev-parse HEAD)
REMOTE=$(git -C "${REPO_DIR}" rev-parse origin/main)

if [ "${LOCAL}" == "${REMOTE}" ]; then
  exit 0
fi

echo "Updating: ${LOCAL} -> ${REMOTE}"
git -C "${REPO_DIR}" reset --hard origin/main

cd "${STACK_DIR}"

# Generate .env if missing
if [ ! -f .env ]; then
  TZ=$(timedatectl show -p Timezone --value 2>/dev/null ||
    cat /etc/timezone 2>/dev/null ||
    readlink /etc/localtime | sed 's|.*/zoneinfo/||')
  cat >.env <<EOF
PUID=$(id -u)
PGID=$(id -g)
TZ=${TZ}
PORTAINER_DATA=${STACK_DATA}
EOF
fi

cat .env
docker compose up --detach --pull always --remove-orphans
docker system prune --force --all --volumes

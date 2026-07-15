#!/usr/bin/env bash
set -euo pipefail

cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/arcane"

# Get default branch and remote HEAD in single call
REMOTE_INFO=$(git ls-remote --symref origin HEAD)
DEFAULT_BRANCH=$(echo "${REMOTE_INFO}" | awk '/^ref:/ {sub("refs/heads/", "", $2); print $2}')
REMOTE_SHA=$(echo "${REMOTE_INFO}" | awk '!/^ref:/ {print $1}')

if [ -z "${DEFAULT_BRANCH}" ] || [ -z "${REMOTE_SHA}" ]; then
  echo "Failed to get remote default branch or SHA" >&2
  exit 1
fi

LOCAL_SHA=$(git rev-parse HEAD)

if [ "${LOCAL_SHA}" == "${REMOTE_SHA}" ]; then
  exit 0
fi

# Fetch and switch to default branch at latest
echo "Updating: ${LOCAL_SHA} -> ${REMOTE_SHA}"
git fetch origin
git switch --force-create --discard-changes "${DEFAULT_BRANCH}" "origin/${DEFAULT_BRANCH}"

# Generate .env if missing
if [ ! -f .env ]; then
  echo "ENCRYPTION_KEY=$(openssl rand -hex 32)" >>.env
  echo "JWT_SECRET=$(openssl rand -hex 32)" >>.env
fi

docker compose up --detach --pull always --remove-orphans

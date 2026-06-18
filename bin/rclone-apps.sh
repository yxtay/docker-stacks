#!/usr/bin/env bash
set -euo pipefail

REPO_DIR=$(git -C "$(dirname "${0}")" rev-parse --show-toplevel)
docker compose -f "${REPO_DIR}/backup/compose.yaml" run --rm rclone-sync

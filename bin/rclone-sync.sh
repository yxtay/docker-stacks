#!/usr/bin/env bash
set -euo pipefail

REPO_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
docker compose -f "${REPO_DIR}/sync/compose.yaml" run --rm rclone

#!/usr/bin/env bash
set -euo pipefail

SYNC_COMPOSE=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/sync/compose.yaml
docker compose -f "${SYNC_COMPOSE}" run --rm rclone

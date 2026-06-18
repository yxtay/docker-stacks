#!/usr/bin/env bash
set -euo pipefail

SYNC_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/sync
docker compose -f "${SYNC_DIR}/compose.yaml" run --rm rsync

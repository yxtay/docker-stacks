#!/usr/bin/env bash
set -euo pipefail

BACKUP_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/backup
docker compose -f "${BACKUP_DIR}/compose.yaml" run --rm rsync

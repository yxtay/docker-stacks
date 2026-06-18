#!/usr/bin/env bash
set -euo pipefail

docker compose -f ${HOME}/docker-stacks/backup/compose.yaml run --rm rclone-sync

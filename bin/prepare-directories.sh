#!/usr/bin/env bash
set -euo pipefail

dirs=(
  /apps
  /backups
  /mnt/remote/cli_mount
  /mnt/remote/decypharr
  /mnt/remote/riven
  /mnt/torrent/downloads
  /mnt/torrent/movies
  /mnt/torrent/shows
)
for dir in "${dirs[@]}"; do
  mkdir -p "${dir}"
done

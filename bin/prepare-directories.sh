#!/usr/bin/env bash
set -euo pipefail

dirs=(
  /apps
  /backups
  /mnt/remote/debrid
  /mnt/torrent/downloads
  /mnt/torrent/movies
  /mnt/torrent/shows
)
for dir in "${dirs[@]}"; do
  mkdir -p "${dir}"
done

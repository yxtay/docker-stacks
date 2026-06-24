#!/usr/bin/env bash
set -euo pipefail

TARGET_USER=${SUDO_USER:-${USER}}

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

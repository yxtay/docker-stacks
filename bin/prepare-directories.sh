#!/usr/bin/env bash
set -euo pipefail

TARGET_USER=${SUDO_USER:-${USER}}

dirs=(
  /apps
  /backups
  /mnt/remote
  /mnt/remote/debrid
  /mnt/torrent
  /mnt/torrent/downloads
  /mnt/torrent/movies
  /mnt/torrent/shows
)
for dir in "${dirs[@]}"; do
  mkdir -p "${dir}"
  chown "${TARGET_USER}:${TARGET_USER}" "${dir}"
done

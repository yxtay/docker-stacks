#!/usr/bin/env bash
set -euo pipefail

TARGET_USER=${SUDO_USER:-${USER}}

dirs=(
  /apps
  /backups
  /mnt/remote
  /mnt/torrent
  /mnt/torrent/downloads
  /mnt/torrent/movies
  /mnt/torrent/shows
  /mnt/usenet
  /mnt/usenet/downloads
  /mnt/usenet/movies
  /mnt/usenet/shows
)
for dir in "${dirs[@]}"; do
  mkdir -p "${dir}"
  chown "${TARGET_USER}:${TARGET_USER}" "${dir}"
done

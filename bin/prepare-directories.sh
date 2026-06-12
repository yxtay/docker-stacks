#!/usr/bin/env bash
set -euo pipefail

TARGET_USER=${SUDO_USER:-${USER}}

dirs=(
  /apps
  /backups
  /mnt/usenet
  /mnt/torrent
)
for dir in "${dirs[@]}"; do
  mkdir -p "${dir}"
  chown ubuntu:ubuntu "${dir}"
done

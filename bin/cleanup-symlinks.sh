#!/usr/bin/env bash
set -euo pipefail

for dir in /mnt/usenet /mnt/torrent; do
  if [[ -d "${dir}" ]]; then
    find "${dir}" -xtype l -delete
  fi
done

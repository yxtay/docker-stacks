#!/usr/bin/env bash
set -euo pipefail

for dir in /mnt/usenet /mnt/torrent; do [ -d "$dir" ] && find "$dir" -xtype l -delete; done

#!/usr/bin/env bash
set -euo pipefail

find /mnt/{usenet,torrent} -xtype l -delete

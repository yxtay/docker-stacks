#!/usr/bin/env bash
set -euo pipefail

LOGROTATE_STATE=${LOGROTATE_STATE:-/apps/logrotate/status}
LOGROTATE_CONF=${LOGROTATE_CONF:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/logrotate/apps.conf}
LOGROTATE_TMP=/tmp/logrotate-apps.conf

mkdir -p "$(dirname "${LOGROTATE_STATE}")"
sudo install -o root -g root -m 644 "${LOGROTATE_CONF}" "${LOGROTATE_TMP}"
sudo logrotate "${LOGROTATE_TMP}" --state "${LOGROTATE_STATE}"

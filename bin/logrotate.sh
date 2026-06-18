#!/usr/bin/env bash
set -euo pipefail

LOGROTATE_STATE=${LOGROTATE_STATE:-/apps/logrotate/status}
LOGROTATE_CONF=${LOGROTATE_CONF:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/logrotate/apps.conf}
mkdir -p "$(dirname "${LOGROTATE_STATE}")"
logrotate "${LOGROTATE_CONF}" --state "${LOGROTATE_STATE}"

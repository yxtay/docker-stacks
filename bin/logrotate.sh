#!/usr/bin/env bash
set -euo pipefail

LOGROTATE_STATE=${LOGROTATE_STATE:-/apps/logrotate/status}
LOGROTATE_CONF=${LOGROTATE_CONF:-$(git -C "$(dirname "${0}")" rev-parse --show-toplevel)/logrotate/apps.conf}
mkdir -p "$(dirname "${LOGROTATE_STATE}")"
logrotate "${LOGROTATE_CONF}" --state "${LOGROTATE_STATE}"

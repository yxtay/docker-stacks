#!/usr/bin/env bash
set -euo pipefail

logrotate_state=/apps/logrotate/status
logrotate_conf=$(git -C "$(dirname "${0}")" rev-parse --show-toplevel)/logrotate/apps.conf
logrotate "${logrotate_conf}" --state "${logrotate_state}"

#!/usr/bin/env bash
set -euo pipefail

logrorate_state=/apps/logrotate/status
logrotate_conf=$(git -C "$(dirname "${0}")" rev-parse --show-toplevel)/logrotate/apps.conf
logrotate "${logrotate_conf}" --state "${logrorate_state}"

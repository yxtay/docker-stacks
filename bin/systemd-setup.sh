#!/usr/bin/env bash
set -euo pipefail

SYSTEMD_DIR=$(git -C "$(dirname "${0}")" rev-parse --show-toplevel)/systemd
SYSTEMD_USER_DIR=${HOME}/.config/systemd/user
TIMERS=($(basename -a "${SYSTEMD_DIR}"/*.timer))

mkdir -p "${SYSTEMD_USER_DIR}"

ln -sf "${SYSTEMD_DIR}/run-script@.service" "${SYSTEMD_USER_DIR}/"
ln -sf "${SYSTEMD_DIR}"/*.timer "${SYSTEMD_USER_DIR}/"

systemctl --user daemon-reload
systemctl --user enable --now "${TIMERS[@]}"

sudo loginctl enable-linger "${USER}"

echo "Systemd user timers installed and enabled: ${TIMERS[*]}"

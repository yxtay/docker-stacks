#!/usr/bin/env bash
set -euo pipefail

REPO_DIR=$(git -C "$(dirname "${0}")" rev-parse --show-toplevel)
SYSTEMD_DIR=${REPO_DIR}/systemd
SYSTEMD_USER_DIR=${HOME}/.config/systemd/user
mapfile -t TIMERS < <(basename -a "${SYSTEMD_DIR}"/*.timer)

mkdir -p "${SYSTEMD_USER_DIR}"

sed "s|%h/docker-stacks|${REPO_DIR}|g" "${SYSTEMD_DIR}/run-script@.service" \
  >"${SYSTEMD_USER_DIR}/run-script@.service"
ln -sf "${SYSTEMD_DIR}"/*.timer "${SYSTEMD_USER_DIR}/"

systemctl --user daemon-reload
systemctl --user enable --now "${TIMERS[@]}"

loginctl enable-linger

echo "Systemd user timers installed and enabled: ${TIMERS[*]}"

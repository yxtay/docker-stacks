#!/bin/sh
set -e

RCLONE_CONFIG="/app/rclone/rclone.conf"
REMOTE_PATH="gdrive:backups/apps-kopia"
SNAPSHOT_PATH="/apps"

# Read repository password from Docker secret
export KOPIA_PASSWORD="$(cat /run/secrets/kopia_password)"

# Write rclone config from environment
mkdir -p /app/rclone
cat >"$RCLONE_CONFIG" <<EOF
[gdrive]
type = drive
scope = drive
service_account_file = /run/secrets/google_service_account
root_folder_id = ${GDRIVE_FOLDER_ID}
EOF

# Create or connect to repository
if ! kopia repository status; then
  kopia repository create rclone \
    --remote-path="$REMOTE_PATH" \
    --rclone-exe=/usr/bin/rclone \
    --rclone-args="--config=$RCLONE_CONFIG" ||
    kopia repository connect rclone \
      --remote-path="$REMOTE_PATH" \
      --rclone-exe=/usr/bin/rclone \
      --rclone-args="--config=$RCLONE_CONFIG"
fi

# Set global policy: retention
kopia policy set --global \
  --keep-latest 7 \
  --keep-daily 7 \
  --keep-weekly 4 \
  --keep-monthly 3

# Set global policy: scheduling (every 24 hours)
kopia policy set --global \
  --snapshot-interval 24h

# Set global policy: exclusions
kopia policy set --global \
  --add-ignore "*.tmp" \
  --add-ignore "*.pid" \
  --add-ignore "*.lock" \
  --add-ignore "tmp/" \
  --add-ignore "temp/" \
  --add-ignore "cache/" \
  --add-ignore "*-wal" \
  --add-ignore "*-shm" \
  --add-ignore "__pycache__/" \
  --add-ignore "*.pyc" \
  --add-ignore "MediaCover/" \
  --add-ignore ".updater/" \
  --add-ignore ".git/" \
  --add-ignore "profilarr/data/databases/" \
  --add-ignore "prowlarr/Definitions/"

# Respect .kopiaignore and .nobackup marker files
kopia policy set --global \
  --add-dot-ignore .kopiaignore \
  --add-dot-ignore .nobackup

# Create initial snapshot source
kopia snapshot create "$SNAPSHOT_PATH" || true

# Start kopia server
exec kopia server start \
  --insecure \
  --address=0.0.0.0:51515 \
  --without-password

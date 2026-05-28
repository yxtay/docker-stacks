#!/bin/bash
set -euo pipefail

# Required:
#   COMPARTMENT_OCID       - target OCI compartment OCID
#   SSH_PUBLIC_KEY         - SSH public key string
#     or SSH_PUBLIC_KEY_FILE - path to public key file (default: ~/.ssh/id_ed25519.pub)
# Optional:
#   STACK_DISPLAY_NAME     - stack/instance name (default: arm-free-tier)

COMPARTMENT_OCID=${COMPARTMENT_OCID:?'COMPARTMENT_OCID is required'}
SSH_PUBLIC_KEY=${SSH_PUBLIC_KEY:-$(cat "${SSH_PUBLIC_KEY_FILE:-$HOME/.ssh/id_ed25519.pub}")}
STACK_DISPLAY_NAME=${STACK_DISPLAY_NAME:-arm-free-tier}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
STACK_ZIP=$(mktemp --suffix=.zip)
VARS_FILE=$(mktemp --suffix=.json)

cleanup() {
  rm -f "$STACK_ZIP" "$VARS_FILE"
}
trap cleanup EXIT

echo "Zipping OCI RM stack..."
(cd "$REPO_ROOT/oci-rm" && zip -r "$STACK_ZIP" .)

echo "Writing variables..."
printf '{"ssh_public_key": %s, "instance_display_name": %s}' \
  "$(printf '%s' "$SSH_PUBLIC_KEY" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')" \
  "$(printf '%s' "$STACK_DISPLAY_NAME" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')" \
  >"$VARS_FILE"

echo "Creating stack..."
STACK_ID=$(oci resource-manager stack create \
  --compartment-id "$COMPARTMENT_OCID" \
  --config-source "$STACK_ZIP" \
  --display-name "$STACK_DISPLAY_NAME" \
  --variables "file://$VARS_FILE" \
  --query 'data.id' \
  --raw-output)
echo "Stack: $STACK_ID"

STACK_ID="$STACK_ID" "$SCRIPT_DIR/oci-rm-stack-apply.sh"

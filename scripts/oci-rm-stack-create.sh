#!/bin/bash
set -euo pipefail

# Creates or updates an OCI Resource Manager stack, then applies it.
#
# Required (create only):
#   COMPARTMENT_OCID       - target OCI compartment OCID (required when STACK_ID unset)
# Required:
#   SSH_PUBLIC_KEY         - SSH public key string
#     or SSH_PUBLIC_KEY_FILE - path to public key file (default: ~/.ssh/id_ed25519.pub)
# Optional:
#   STACK_ID               - existing stack OCID; if set, updates instead of creates
#   STACK_DISPLAY_NAME     - stack/instance name (default: oci-rm-arm-free-tier)
#   USER_DATA_FILE         - cloud-init script path (default: scripts/init.sh)

SSH_PUBLIC_KEY=${SSH_PUBLIC_KEY:-$(cat "${SSH_PUBLIC_KEY_FILE:-$HOME/.ssh/id_ed25519.pub}")}
STACK_DISPLAY_NAME=${STACK_DISPLAY_NAME:-oci-rm-arm-free-tier}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
USER_DATA_FILE=${USER_DATA_FILE:-"${SCRIPT_DIR}/init.sh"}
WORK_DIR=$(mktemp -d "${TMPDIR:-/tmp}/oci-rm.XXXXXX")
STACK_ZIP="${WORK_DIR}/stack.zip"
VARS_FILE="${WORK_DIR}/vars.json"

cleanup() {
  rm -rf "${WORK_DIR}"
}
trap cleanup EXIT

echo "Zipping OCI RM stack..."
(cd "${REPO_ROOT}/oci-rm" && zip -r "${STACK_ZIP}" .)

echo "Writing variables..."
jq -n \
  --arg ssh_public_key "${SSH_PUBLIC_KEY}" \
  --arg instance_display_name "${STACK_DISPLAY_NAME}" \
  --rawfile user_data "${USER_DATA_FILE}" \
  '{ssh_public_key: $ssh_public_key, instance_display_name: $instance_display_name, user_data: $user_data}' \
  >"${VARS_FILE}"

if [[ -n "${STACK_ID:-}" ]]; then
  echo "Updating stack ${STACK_ID}..."
  oci resource-manager stack update \
    --stack-id "${STACK_ID}" \
    --config-source "${STACK_ZIP}" \
    --display-name "${STACK_DISPLAY_NAME}" \
    --variables "file://${VARS_FILE}" \
    --force
  echo "Stack updated."
else
  COMPARTMENT_OCID=${COMPARTMENT_OCID:?'COMPARTMENT_OCID is required when STACK_ID is unset'}
  echo "Creating stack..."
  STACK_ID=$(oci resource-manager stack create \
    --compartment-id "${COMPARTMENT_OCID}" \
    --config-source "${STACK_ZIP}" \
    --display-name "${STACK_DISPLAY_NAME}" \
    --variables "file://${VARS_FILE}" \
    --query 'data.id' \
    --raw-output)
  echo "Stack: ${STACK_ID}"
fi

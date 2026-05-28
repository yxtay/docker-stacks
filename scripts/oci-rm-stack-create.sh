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

SSH_PUBLIC_KEY=${SSH_PUBLIC_KEY:-$(cat "${SSH_PUBLIC_KEY_FILE:-$HOME/.ssh/id_ed25519.pub}")}
STACK_DISPLAY_NAME=${STACK_DISPLAY_NAME:-oci-rm-arm-free-tier}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
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
printf '{"ssh_public_key": %s, "instance_display_name": %s}' \
  "$(printf '%s' "${SSH_PUBLIC_KEY}" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')" \
  "$(printf '%s' "${STACK_DISPLAY_NAME}" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')" \
  >"${VARS_FILE}"

if [[ -n "${STACK_ID:-}" ]]; then
  echo "Merging variables with existing stack..."
  EXISTING_VARS=$(oci resource-manager stack get \
    --stack-id "${STACK_ID}" \
    --query 'data.variables' \
    --raw-output)
  python3 -c "
import json, sys
existing = json.loads(sys.argv[1])
existing.update(json.load(open(sys.argv[2])))
print(json.dumps(existing))
" "${EXISTING_VARS}" "${VARS_FILE}" >"${VARS_FILE}.merged"
  mv "${VARS_FILE}.merged" "${VARS_FILE}"

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

STACK_ID="${STACK_ID}" "${SCRIPT_DIR}/oci-rm-stack-apply.sh"

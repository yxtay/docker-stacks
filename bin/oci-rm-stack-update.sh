#!/usr/bin/env bash
set -euo pipefail

# Updates the Terraform config of an OCI Resource Manager stack.
# Does not modify stack variables.
#
# Required:
#   STACK_ID               - existing stack OCID

STACK_ID=${STACK_ID:?'STACK_ID is required'}

REPO_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
WORK_DIR=$(mktemp -d "${TMPDIR:-/tmp}/oci-rm.XXXXXX")
STACK_ZIP="${WORK_DIR}/stack.zip"

trap 'rm -rf "${WORK_DIR}"' EXIT
echo "Zipping OCI RM stack..."
(cd "${REPO_DIR}/oci-rm" && zip -r "${STACK_ZIP}" .)

echo "Updating stack ${STACK_ID}..."
oci resource-manager stack update \
  --stack-id "${STACK_ID}" \
  --config-source "${STACK_ZIP}" \
  --force
echo "Stack updated."

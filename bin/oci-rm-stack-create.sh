#!/usr/bin/env bash
set -euo pipefail

# Creates an OCI Resource Manager stack from the oci-rm/ Terraform config.
# Gathers region, tenancy_ocid, and compartment_ocid from OCI CLI config.
#
# Required:
#   SSH_PUBLIC_KEY         - SSH public key for instance access
#                            (e.g. SSH_PUBLIC_KEY="$(ssh-add -L | tail -1)")
#
# Optional:
#   COMPARTMENT_ID         - target compartment (defaults to first sub-compartment)
#   STACK_NAME             - stack display name (defaults to "orm-ampere-a1-ubuntu")
#   STACK_DESCRIPTION      - stack description

SSH_PUBLIC_KEY=${SSH_PUBLIC_KEY:?}
STACK_NAME=${STACK_NAME:-"orm-ampere-a1-ubuntu"}
STACK_DESCRIPTION=${STACK_DESCRIPTION:-"Creates an Ampere A1 (ARM) Always Free VPS on Oracle Cloud Infrastructure"}

REGION=$(oci iam region-subscription list --query 'data[?"is-home-region"] | [0]."region-name"' --raw-output)
TENANCY_OCID=$(oci iam availability-domain list --query 'data[0]."compartment-id"' --raw-output)
COMPARTMENT_ID=${COMPARTMENT_ID:-$(oci iam compartment list --compartment-id-in-subtree true --query 'data[0].id' --raw-output)}
COMPARTMENT_ID=${COMPARTMENT_ID:-${TENANCY_OCID}}

REPO_DIR=$(git -C "$(dirname "${0}")" rev-parse --show-toplevel)
WORK_DIR=$(mktemp -d "${TMPDIR:-/tmp}/oci-rm.XXXXXX")
STACK_ZIP="${WORK_DIR}/stack.zip"

trap 'rm -rf "${WORK_DIR}"' EXIT
echo "Zipping OCI RM stack..."
(cd "${REPO_DIR}/oci-rm" && zip -r "${STACK_ZIP}" .)

echo "Creating stack ${STACK_NAME} in ${REGION}..."
oci resource-manager stack create \
  --compartment-id "${COMPARTMENT_ID}" \
  --config-source "${STACK_ZIP}" \
  --display-name "${STACK_NAME}" \
  --description "${STACK_DESCRIPTION}" \
  --variables "{\"tenancy_ocid\":\"${TENANCY_OCID}\",\"compartment_ocid\":\"${COMPARTMENT_ID}\",\"region\":\"${REGION}\",\"ssh_public_key\":\"${SSH_PUBLIC_KEY}\"}"

echo "Stack created."

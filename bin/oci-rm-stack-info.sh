#!/usr/bin/env bash
set -euo pipefail

# Shows metadata for OCI Resource Manager stacks.
#
# Optional:
#   STACK_ID               - show full details for a specific stack
#   COMPARTMENT_ID         - compartment to list stacks from
#                            (defaults to first sub-compartment)

if [[ -n "${STACK_ID:-}" ]]; then
  oci resource-manager stack get --stack-id "${STACK_ID}"
else
  COMPARTMENT_ID=${COMPARTMENT_ID:-$(oci iam compartment list --compartment-id-in-subtree true --query 'data[0].id' --raw-output)}
  COMPARTMENT_ID=${COMPARTMENT_ID:-$(oci iam availability-domain list --query 'data[0]."compartment-id"' --raw-output)}
  LIST_OUTPUT=$(oci resource-manager stack list --compartment-id "${COMPARTMENT_ID}")
  COUNT=$(echo "${LIST_OUTPUT}" | jq '.data | length')
  if [[ "${COUNT}" -eq 1 ]]; then
    SINGLE_ID=$(echo "${LIST_OUTPUT}" | jq -r '.data[0].id')
    oci resource-manager stack get --stack-id "${SINGLE_ID}"
  else
    echo "${LIST_OUTPUT}"
  fi
fi

#!/bin/bash

set -euo pipefail

# Required:
#   TENANCY_OCID           - OCI tenancy OCID
#   COMPARTMENT_OCID       - target OCI compartment OCID
#   REGION                 - OCI region (e.g. ap-singapore-1)
#   SSH_PUBLIC_KEY         - SSH public key string
#     or SSH_PUBLIC_KEY_FILE - path to public key file (default: ~/.ssh/id_ed25519.pub)

TENANCY_OCID=${TENANCY_OCID:?'TENANCY_OCID is required'}
COMPARTMENT_OCID=${COMPARTMENT_OCID:?'COMPARTMENT_OCID is required'}
REGION=${REGION:?'REGION is required'}
SSH_PUBLIC_KEY=${SSH_PUBLIC_KEY:-$(cat "${SSH_PUBLIC_KEY_FILE:-$HOME/.ssh/id_ed25519.pub}")}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_DIR="$(cd "$SCRIPT_DIR/../oci-rm" && pwd)"

cd "$TF_DIR"

terraform init

terraform plan \
  -var "tenancy_ocid=$TENANCY_OCID" \
  -var "compartment_ocid=$COMPARTMENT_OCID" \
  -var "region=$REGION" \
  -var "ssh_public_key=$SSH_PUBLIC_KEY"

terraform apply \
  -var "tenancy_ocid=$TENANCY_OCID" \
  -var "compartment_ocid=$COMPARTMENT_OCID" \
  -var "region=$REGION" \
  -var "ssh_public_key=$SSH_PUBLIC_KEY"

echo "Outputs:"
terraform output

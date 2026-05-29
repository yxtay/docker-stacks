#!/bin/bash
set -euo pipefail

# Submits an apply job on an existing OCI Resource Manager stack.
# Designed for cron: runs once, skips if instance already provisioned
# or a job is currently in progress.
#
# Required:
#   STACK_ID    - OCI Resource Manager stack OCID
# Optional:
#   FORCE_APPLY - set to "true" to skip the SUCCEEDED check

STACK_ID=${STACK_ID:?'STACK_ID is required'}

# Check latest job — skip if already succeeded or in progress
read -r LATEST_JOB_ID LATEST_STATUS <<<"$(oci resource-manager job list \
  --stack-id "${STACK_ID}" \
  --sort-by TIMECREATED \
  --sort-order DESC \
  --limit 1 \
  --query 'data[0].[id, "lifecycle-state"]' \
  --output text 2>/dev/null || true)"

if [[ "${LATEST_STATUS}" == "SUCCEEDED" ]]; then
  echo "Stack already applied successfully. Skipping."
  exit 0
elif [[ "${LATEST_STATUS}" == "IN_PROGRESS" || "${LATEST_STATUS}" == "ACCEPTED" ]]; then
  echo "Job already running (${LATEST_STATUS}). Skipping."
  exit 0
elif [[ "${LATEST_STATUS}" == "FAILED" || "${LATEST_STATUS}" == "CANCELED" ]]; then
  echo "Previous job ${LATEST_JOB_ID} ${LATEST_STATUS}. Logs:"
  LOGS=$(oci resource-manager job get-job-logs \
    --job-id "${LATEST_JOB_ID}" \
    --query 'data[*].message' \
    --output text 2>/dev/null || true)
  echo "${LOGS}"
  if ! echo "${LOGS}" | grep -qi "out of host capacity\|out of capacity"; then
    echo "Non-capacity failure. Skipping to prevent retry loop." >&2
    exit 1
  fi
fi

# Submit apply job
echo "Creating apply job..."
if ! JOB_ID=$(oci resource-manager job create-apply-job \
  --stack-id "${STACK_ID}" \
  --execution-plan-strategy AUTO_APPROVED \
  --query 'data.id' \
  --raw-output 2>&1); then
  echo "Failed to create job: ${JOB_ID}" >&2
  exit 1
fi

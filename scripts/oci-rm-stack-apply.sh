#!/bin/bash
set -euo pipefail

# Submits an apply job on an existing OCI Resource Manager stack.
# Designed for cron: runs once, skips if instance already provisioned
# or a job is currently in progress.
#
# Required:
#   STACK_ID - OCI Resource Manager stack OCID

STACK_ID=${STACK_ID:?'STACK_ID is required'}

# Check latest job — skip if already succeeded or in progress
LATEST_JOB=$(oci resource-manager job list \
  --stack-id "${STACK_ID}" \
  --sort-by TIMECREATED \
  --sort-order DESC \
  --limit 1 \
  --query 'data[0].{id:id,status:"lifecycle-state"}' \
  --output json 2>/dev/null || echo '{}')

LATEST_STATUS=$(echo "${LATEST_JOB}" | jq -r '.status // empty')
LATEST_JOB_ID=$(echo "${LATEST_JOB}" | jq -r '.id // empty')

if [[ "${LATEST_STATUS}" == "SUCCEEDED" ]]; then
  echo "Stack already applied successfully. Skipping."
  exit 0
elif [[ "${LATEST_STATUS}" == "IN_PROGRESS" || "${LATEST_STATUS}" == "ACCEPTED" ]]; then
  echo "Job already running (${LATEST_STATUS}). Skipping."
  exit 0
elif [[ "${LATEST_STATUS}" == "FAILED" || "${LATEST_STATUS}" == "CANCELED" ]]; then
  echo "Previous job ${LATEST_JOB_ID} ${LATEST_STATUS}. Logs:"
  oci resource-manager job get-job-logs \
    --job-id "${LATEST_JOB_ID}" \
    --query 'data[*].message' \
    --output table 2>/dev/null || true
  echo ""
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

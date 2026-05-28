#!/bin/bash
set -euo pipefail

# Retries an apply job on an existing OCI Resource Manager stack until it
# succeeds. Intended for "Out of host capacity" errors on A1.Flex Free Tier.
#
# Required:
#   STACK_ID         - OCI Resource Manager stack OCID
# Optional:
#   RETRY_INTERVAL   - seconds between retries (default: 300)
#   MAX_RETRIES      - max attempts before giving up; 0 = unlimited (default: 0)

STACK_ID=${STACK_ID:?'STACK_ID is required'}
RETRY_INTERVAL=${RETRY_INTERVAL:-300}
MAX_RETRIES=${MAX_RETRIES:-0}

attempt=0

while true; do
  attempt=$((attempt + 1))

  if [[ $MAX_RETRIES -gt 0 && $attempt -gt $MAX_RETRIES ]]; then
    echo "Max retries ($MAX_RETRIES) reached." >&2
    exit 1
  fi

  echo "Attempt $attempt: creating apply job..."
  JOB_ID=$(oci resource-manager job create-apply-job \
    --stack-id "$STACK_ID" \
    --execution-plan-strategy AUTO_APPROVED \
    --query 'data.id' \
    --raw-output)
  echo "Job: $JOB_ID"

  # Poll until terminal state
  STATUS=""
  while true; do
    STATUS=$(oci resource-manager job get \
      --job-id "$JOB_ID" \
      --query 'data."lifecycle-state"' \
      --raw-output)
    echo "  Status: $STATUS"
    case "$STATUS" in
    SUCCEEDED | FAILED | CANCELING | CANCELED) break ;;
    esac
    sleep 15
  done

  if [[ "$STATUS" == "SUCCEEDED" ]]; then
    echo "Done! View outputs at:"
    echo "  https://cloud.oracle.com/resourcemanager/stacks/$STACK_ID"
    exit 0
  fi

  # Check whether failure was a capacity error
  LOGS=$(oci resource-manager job get-job-logs \
    --job-id "$JOB_ID" \
    --query 'data[*].message' \
    --output json 2>/dev/null || echo '[]')

  if echo "$LOGS" | grep -qi "out of host capacity\|out of capacity"; then
    echo "Out of capacity. Retrying in ${RETRY_INTERVAL}s (Ctrl-C to stop)..."
    sleep "$RETRY_INTERVAL"
  else
    echo "Job failed for a non-capacity reason. Check logs:" >&2
    echo "  oci resource-manager job get-job-logs --job-id $JOB_ID" >&2
    exit 1
  fi
done

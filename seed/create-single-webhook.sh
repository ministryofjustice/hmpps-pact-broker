#!/bin/bash -e
set -o pipefail

if [ "$1" = "" ] || [ "$2" = "" ] || [ "$3" = "" ]; then
  echo "Usage: $0 <webhook-name> <webhook-id> <token-placeholder>"
  echo "Example: $0 hmpps-person-record ctNyAoj2Rx6pJYuJSpYChw hmpps-person-record_ACCESS_TOKEN"
  exit 1
fi

WEBHOOK_NAME="$1"
WEBHOOK_ID="$2"
TOKEN_VAR="$3"
TOKEN_VALUE="${WEBHOOK_TOKEN:?WEBHOOK_TOKEN must be set}"
FILE="webhook-${WEBHOOK_NAME}.json"

: "${PACT_BROKER_URL:?PACT_BROKER_URL must be set}"
: "${PACT_BROKER_USERNAME:?PACT_BROKER_USERNAME must be set}"
: "${PACT_BROKER_PASSWORD:?PACT_BROKER_PASSWORD must be set}"

if [ ! -f "$FILE" ]; then
  echo "Error: File $FILE does not exist."
  exit 1
fi

function upsert_webhook() {
  local file="$1"
  local webhookID="$2"
  echo "Applying $file..."
  sed "s|\${${TOKEN_VAR}}|$TOKEN_VALUE|g" "$file" |
    curl --fail --silent --show-error --output /dev/null -X PUT \
      "${PACT_BROKER_URL%/}/webhooks/$webhookID" \
      --user "$PACT_BROKER_USERNAME:$PACT_BROKER_PASSWORD" \
      -H "Content-Type: application/json" \
      -d @-
  echo "Webhook applied."
}

upsert_webhook "$FILE" "$WEBHOOK_ID"
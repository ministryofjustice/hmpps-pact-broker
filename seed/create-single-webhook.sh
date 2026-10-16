#!/bin/bash -e

if [ "$1" = "" ] || [ "$2" = "" ]; then
  echo "Usage: $0 <webhook-name> <webhook-id>"
  echo "Example: $0 court-case-service 357828ada55a4ba1bf4f3bd846ed4d96"
  exit 1
fi

WEBHOOK_NAME="$1"
WEBHOOK_ID="$2"
TOKEN_VAR="$3"
TOKEN_VALUE="${!TOKEN_VAR}"
FILE="webhook-${WEBHOOK_NAME}.json"

if [ ! -f "$FILE" ]; then
  echo "Error: File $FILE does not exist."
  exit 1
fi

function upsert_webhook() {
  local file="$1"
  local webhookID="$2"
  echo "✨ applying $file..."
  sed "s/\${TOKEN_VAR}/$TOKEN_VALUE/g" "$file" |
    curl -X PUT \
      "https://pact-broker-prod.apps.live-1.cloud-platform.service.justice.gov.uk/webhooks/$webhookID" \
      --user "$PACT_BROKER_USERNAME:$PACT_BROKER_PASSWORD" \
      -H "Content-Type: application/json" \
      -d @-
  echo
  echo
}

upsert_webhook "$FILE" "$WEBHOOK_ID"

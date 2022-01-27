#!/bin/bash -e

if [ "$CIRCLE_TOKEN" = "" ] || [ "$GITHUB_ACCESS_TOKEN" = "" ] || [ "$PACT_BROKER_USERNAME" = "" ] || [ "$PACT_BROKER_PASSWORD" = "" ]; then
  echo "One or more environment variables are missing. Usage:"
  echo "CIRCLE_TOKEN=token GITHUB_ACCESS_TOKEN=token PACT_BROKER_USERNAME=user PACT_BROKER_PASSWORD=password $0"
  exit 1
fi

function upsert_webhook() {
  local file="$1"
  local webhookID="$2"
  echo "✨ applying $file..."
  sed "s/\${CIRCLE_TOKEN}/$CIRCLE_TOKEN/; s/\${GITHUB_ACCESS_TOKEN}/$GITHUB_ACCESS_TOKEN/" "$file" |
    curl -X PUT \
      "https://pact-broker-prod.apps.live-1.cloud-platform.service.justice.gov.uk/webhooks/$webhookID" \
      --user "$PACT_BROKER_USERNAME:$PACT_BROKER_PASSWORD" \
      -H "Content-Type: application/json" \
      -d @-
  echo
  echo
}

# these ".../webhooks/ID" IDs are randomly chosen -- they will be either "created or updated" so pick anything for new webhooks
# for pedantics: Pact generates these via `SecureRandom.urlsafe_base64`: https://ruby-doc.org/stdlib-3.0.1/libdoc/securerandom/rdoc/Random/Formatter.html#method-i-urlsafe_base64
upsert_webhook "webhook-interventions-service.json" "4wniGo-GXnLTM6Qx1YqlmQ"
upsert_webhook "webhook-interventions-ui-feedback.json" "3XLeJJv8Lh4yiTk0nBDMoQ"
upsert_webhook "webhook-court-case-service.json" "357828ada55a4ba1bf4f3bd846ed4d96"
upsert_webhook "webhook-prepare-a-case-feedback.json" "90a734c0f0654594a76c7472e0f3646a"

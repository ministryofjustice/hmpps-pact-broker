#!/bin/sh -e

if [ "x$CIRCLE_TOKEN" = "x" ] || [ "x$PACT_BROKER_USERNAME" = "x" ] || [ "x$PACT_BROKER_PASSWORD" = "x" ]; then
  echo "One or more environment variables are missing. Usage:"
  echo "CIRCLE_TOKEN=token PACT_BROKER_USERNAME=user PACT_BROKER_PASSWORD=password $0"
  exit 1
fi

sed "s/\${CIRCLE_TOKEN}/$CIRCLE_TOKEN/" webhook-interventions-service.json |
  curl -X PUT \
    "https://pact-broker-prod.apps.live-1.cloud-platform.service.justice.gov.uk/webhooks/4wniGo-GXnLTM6Qx1YqlmQ" \
    --user "$PACT_BROKER_USERNAME:$PACT_BROKER_PASSWORD" \
    -H "Content-Type: application/json" \
    -d @-

# hmpps-pact-broker

This repository contains the deployment script for the [Pact broker](https://docs.pact.io/pact_broker)
used by the interventions team in HMPPS.

It deploys the [`pactfoundation/pact-broker`](https://hub.docker.com/r/pactfoundation/pact-broker) image,
see [`kubectl-deploy/deployment.yml`](kubectl-deploy/deployment.yml) for details.

## Pre-requisites

- [Access to Cloud Platform](https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/kubectl-config.html#authentication)
- Access to the [`pact-broker-prod`](https://github.com/ministryofjustice/cloud-platform-environments/tree/8eef196708c5fd07c3fe1ba1fe2f95dbcefcb567/namespaces/live-1.cloud-platform.service.justice.gov.uk/pact-broker-prod) namespace

## Deploy

```
./deploy.sh
```

## Create webhooks

Webhooks can trigger builds when contract changes are pushed by consumers.

To populate,

```
cd seed
CIRCLE_TOKEN=token PACT_BROKER_USERNAME=username PACT_BROKER_PASSWORD=password ./create_webhooks.sh
```

- `CIRCLE_TOKEN` to be used by webhooks to CircleCI, used by the CircleCI v2 API. Please generate one.
- `PACT_BROKER_USERNAME` and `PACT_BROKER_PASSWORD` are the basic auth username/password. Please see the Kubernetes secrets.

:rotating_light: The tokens are redacted in the output and the Pact broker UI.
However, they are visible in the database.

## Secrets

All variables are saved in the Kubernetes secrets under the namespace `pact-broker-prod`.

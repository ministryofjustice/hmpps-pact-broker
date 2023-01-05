[![Deploy](https://github.com/ministryofjustice/hmpps-pact-broker/actions/workflows/publish.yml/badge.svg)](https://github.com/ministryofjustice/hmpps-pact-broker/actions/workflows/publish.yml)

# hmpps-pact-broker

This repository contains the deployment script for the [Pact broker](https://docs.pact.io/pact_broker)
used by the interventions team in HMPPS.

It deploys the [`pactfoundation/pact-broker`](https://hub.docker.com/r/pactfoundation/pact-broker) image,
see [`kubectl-deploy/deployment.yml`](kubectl-deploy/deployment.yml) for details.

## Pre-requisites

- [Access to Cloud Platform](https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/kubectl-config.html#authentication)
- Access to the [`pact-broker-prod`](https://github.com/ministryofjustice/cloud-platform-environments/tree/8eef196708c5fd07c3fe1ba1fe2f95dbcefcb567/namespaces/live-1.cloud-platform.service.justice.gov.uk/pact-broker-prod) namespace
  (through the [`pact-broker-maintainers`](https://github.com/orgs/ministryofjustice/teams/pact-broker-maintainers) GitHub team)

## Deploy

Each `main` commit deploys the application via [`./deploy.sh`](./deploy.sh)

## Create webhooks

All webhooks are in the [`seed`](./seed) directory and are all automatically deployed
during `main` build via [`seed/create-webhooks.sh`](./seed/create-webhooks.sh)

### When to use webhooks

Webhooks can trigger builds when

- contract changes are pushed by consumers (to trigger a build: [example](seed/webhook-interventions-service.json))
- when the build result is back (to communicate the status to github PR/commit status: [example](seed/webhook-interventions-ui-feedback.json))

### Webhook configuration

All found [under repository secrets](https://github.com/ministryofjustice/hmpps-pact-broker/settings/secrets/actions):

- `PACT_BROKER_CIRCLECI_INTEGRATION_TOKEN` to be used by webhooks to CircleCI, used by the CircleCI v2 API. Please generate one.
- `GH_ACCESS_TOKEN` to be used by Pact to signal the verification result as a GitHub status. Needs a [personal access token][pat], and [authorised SAML][saml].
- `PACT_BROKER_USERNAME` and `PACT_BROKER_PASSWORD` are the basic auth username/password. Please see the Kubernetes secrets.

## Secrets

All variables are saved in the Kubernetes secrets under the namespace `pact-broker-prod`.

[pat]: https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token
[saml]: https://docs.github.com/en/github/authenticating-to-github/authenticating-with-saml-single-sign-on/authorizing-a-personal-access-token-for-use-with-saml-single-sign-on

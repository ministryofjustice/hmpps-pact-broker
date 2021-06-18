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

:rotating_light: Deployment is **manual**; after changes get merged, you must execute:

```
./deploy.sh
```

## Create webhooks

Webhooks can trigger builds when contract changes are pushed by consumers.

To populate,

```
cd seed
CIRCLE_TOKEN=token GITHUB_ACCESS_TOKEN=token PACT_BROKER_USERNAME=username PACT_BROKER_PASSWORD=password ./create_webhooks.sh
```

- `CIRCLE_TOKEN` to be used by webhooks to CircleCI, used by the CircleCI v2 API. Please generate one.
- `GITHUB_ACCESS_TOKEN` to be used by Pact to signal the verification result as a GitHub status. Needs a [personal access token][pat], and [authorised SAML][saml].
- `PACT_BROKER_USERNAME` and `PACT_BROKER_PASSWORD` are the basic auth username/password. Please see the Kubernetes secrets.

:rotating_light: The tokens are redacted in the output and the Pact broker UI.
However, they are visible in the database.

## Secrets

All variables are saved in the Kubernetes secrets under the namespace `pact-broker-prod`.

[pat]: https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token
[saml]: https://docs.github.com/en/github/authenticating-to-github/authenticating-with-saml-single-sign-on/authorizing-a-personal-access-token-for-use-with-saml-single-sign-on

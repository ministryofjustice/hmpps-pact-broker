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

- `PACT_BROKER_CIRCLECI_INTEGRATION_TOKEN` to trigger workflows with webhooks in CircleCI, used by the CircleCI v2 API. Please generate one.
- `GH_ACCESS_TOKEN` to set the verification result as a GitHub build status on a commit. It needs a [personal access token][pat] with `repo:status` permission and [authorised SAML][saml].
- `PACT_BROKER_USERNAME` and `PACT_BROKER_PASSWORD` are the basic auth username/password.

## Secrets

| Secret | In GitHub | In CircleCI | In Kubernetes | How to refresh |
| --- | --- | --- | --- | --- |
| `PACT_BROKER_CIRCLECI_INTEGRATION_TOKEN` | ✅ [yes][gh-secrets] | no | no | Generate a [new CircleCI Personal API Token](https://app.circleci.com/settings/user/tokens) |
| `GH_ACCESS_TOKEN` | ✅ [yes][gh-secrets] | no | no | [Generate][pat] a new GitHub [PAT][setting-pat] with `repo:status` permission. Please "**Configure SSO**" on the token. |
| `PACT_BROKER_PASSWORD` | ✅ [yes][gh-secrets] | ✅ yes, [hmpps-common-vars] | ✅ yes, `secret/basic-auth` | Create a new random password, update the Kubernetes secret, the CircleCI context and the GitHub action secret. |

`PACT_BROKER_USERNAME` is in the same place as `PACT_BROKER_PASSWORD`, but it is not a secret.


[pat]: https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token
[setting-pat]: https://github.com/settings/tokens
[saml]: https://docs.github.com/en/github/authenticating-to-github/authenticating-with-saml-single-sign-on/authorizing-a-personal-access-token-for-use-with-saml-single-sign-on
[gh-secrets]: https://github.com/ministryofjustice/hmpps-pact-broker/settings/secrets/actions
[circleci-pat]: https://app.circleci.com/settings/user/tokens
[hmpps-common-vars]: https://app.circleci.com/settings/organization/github/ministryofjustice/contexts/39e77e3c-466c-460e-9030-159bb4f7c3c7

## Database Upgrade
Follow cloud platform [guide](https://user-guide.cloud-platform.service.justice.gov.uk/documentation/deploying-an-app/relational-databases/upgrade.html). Note this will result in downtime

1. Update [terraform](https://github.com/ministryofjustice/cloud-platform-environments/blob/main/namespaces/live.cloud-platform.service.justice.gov.uk/pact-broker-prod/resources/rds-postgres14.tf) for rds db prepare_for_major_upgrade, rds_family, db_engine_version, allow_major_version_upgrade
    ```terraform
    ...
      prepare_for_major_upgrade   = true
      rds_family                  = "postgres15"
      db_engine_version           = "15"

      allow_major_version_upgrade = true
      allow_minor_version_upgrade = true
    ...
    ```
1. Raise PR in slack channel `#ask-cloud-platform`
1. Mention downtime window in slack channel `#pact-broker`
1. Merge > Triggers DB Upgrade (Downtime starts)

### Troubleshooting DB
Check Pact Broker logs: `kubectl logs -f --tail=500 <pod-name> -n <namespace>`

1. Query timeout (QueryCanceled)
    ```
    2026-08-21 07:52:09.545660 I [8:puma srv tp 001] PactBroker::Matrix::Service -- Querying matrix -- {selectors: [{pacticipant_name: "Interventions UI", pacticipant_version_number: "1463ba3968de941f5095985f887e090fa4fd80cc"}, {pacticipant_name: "Interventions Service"}], options: {latestby: "cvpv", limit: "100", ignore_selectors: []}}

    2026-08-21 07:53:07.483766 E [8:puma srv tp 001 logger.rb:158] Padrino -- Sequel::DatabaseError - PG::QueryCanceled: ERROR:  canceling statement due to statement timeout 
    ```
    1. Check connection details for database in [AWS](https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/accessing-the-cloud-console.html)
    1. Create `pg-tool` to run indexing command
        ``` bash
        kubectl run pg-tool -n <namespace> \    
          --image=postgres:15-alpine \
          --restart=Never \
          --overrides='{
            "spec": {
              "securityContext": {
                "runAsNonRoot": true,
                "runAsUser": 70
              },
              "containers": [{
                "name": "db-tool",
                "image": "postgres:15-alpine",
                "command": ["sleep", "3600"],
                "resources": {
                  "requests": {"memory": "500Mi", "cpu": "250m"},
                  "limits": {"memory": "500Mi", "cpu": "500m"}
                }
              }]
            }
          }'
        ```
    1. Run `ANALYZE` query on `pg-tool` pod
        ```
        kubectl exec pg-tool -it -n <namespace> \
        -- \                       
        psql -h <db-host-name> -U <db-username> -d <db-name> -c "ANALYZE VERBOSE;"
        ```
    1. Restart Pact Broker `kubectl rollout restart deployment pact-broker -n <namespace>`
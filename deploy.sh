#!/bin/sh -e
kubectl apply \
  -f kubectl-deploy/deployment.yml \
  -f kubectl-deploy/service.yml \
  -f kubectl-deploy/ingress.yml \
  --namespace pact-broker-prod
# By default 'rollout status' will watch the status of the latest rollout until it's done.
kubectl rollout status deployment --namespace pact-broker-prod --timeout 1m

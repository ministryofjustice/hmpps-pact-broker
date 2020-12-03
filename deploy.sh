#!/bin/sh -e
kubectl apply \
  -f kubectl-deploy/deployment.yml \
  -f kubectl-deploy/service.yml \
  -f kubectl-deploy/ingress.yml \
  --namespace pact-broker-prod

#!/usr/bin/env bash

NAME_SPACE="docker"
DEPLOY_TYPE="apply"

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

cleanup() {
    trap - SIGINT SIGTERM ERR EXIT
    exit
}

echo ""
echo "${NAME_SPACE} ${DEPLOY_TYPE}..."
echo ""

KUBE_CONFIG="$HOME/.kube/config"

IF_NS=$(kubectl --kubeconfig "$KUBE_CONFIG" get ns | grep "$NAME_SPACE")

if [ -z "$IF_NS" ]; then
    kubectl --kubeconfig "$KUBE_CONFIG" create namespace "$NAME_SPACE"
fi

kubectl --kubeconfig "$KUBE_CONFIG" ${DEPLOY_TYPE} -n ${NAME_SPACE} -k kustomize

#!/usr/bin/env bash
 
NAME_SPACE="docker"

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

cleanup() {
    trap - SIGINT SIGTERM ERR EXIT
    exit
}

echo ""
echo "seegene cluster ${NAME_SPACE} pvc apply..."
echo ""

KUBE_CONFIG="$HOME/.kube/config"

kubectl --kubeconfig $KUBE_CONFIG apply -f ../kustomize/pvc.yaml


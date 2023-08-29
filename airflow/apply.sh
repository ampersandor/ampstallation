#!/bin/bash

NAME_SPACE="airflow"
KUBE_CONFIG="$HOME/.kube/config"
GIT_SECRET="$HOME/.ssh/k8s_sg_gitlab"

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

cleanup() {
    trap - SIGINT SIGTERM ERR EXIT
    exit
}

echo "[0/6] Check if namespace exists"
IF_NS=$(kubectl --kubeconfig "$KUBE_CONFIG" get ns | grep "$NAME_SPACE")
if [ -z "$IF_NS" ]; then
    kubectl --kubeconfig "$KUBE_CONFIG" create namespace "$NAME_SPACE"
else
    echo "$NAME_SPACE already exists."
fi

echo "[1/6] Check if helm repo exists"
IF_REPO=$(helm repo list | grep "apache-airflow")
if [ -z "$IF_REPO" ]; then
    helm repo add apache-airflow https://airflow.apache.org
else
    echo "apache-airflow already exists."
fi

echo "[2/6] Create values.yaml"
values="values.yaml"
if [ -e "$values" ]; then
    echo "$values already exists."
else
    helm show values apache-airflow/airflow > "$values"
    echo "$values created."
fi


echo "[3/6] Create webserver secret if not exists"
IF_SECRET=$(kubectl --kubeconfig "$KUBE_CONFIG" get secret -n "$NAME_SPACE" | grep "airflow-webserver-secret")
if [ -z "$IF_SECRET" ]; then
    kubectl --kubeconfig "$KUBE_CONFIG" create secret generic airflow-webserver-secret -n "$NAME_SPACE" --from-literal="webserver-secret-key=$(python3 -c 'import secrets; print(secrets.token_hex(16))')"
else
    echo "airflow-webserver-secret already exists."
fi

echo "[4/6] Create git secret if not exists"
IF_SECRET=$(kubectl --kubeconfig "$KUBE_CONFIG" get secret -n "$NAME_SPACE" | grep "airflow-ssh-git-secret")
if [ -z "$IF_SECRET" ]; then
    kubectl --kubeconfig "$KUBE_CONFIG" create secret generic airflow-ssh-git-secret --from-file=gitSshKey="${GIT_SECRET}" --namespace "$NAME_SPACE"
else
    echo "airflow-ssh-git-secret already exists."
fi

echo "[5/6] Apply variables if exists"
variables="variables.yaml"
if [ -e "$variables" ]; then
    kubectl --kubeconfig "$KUBE_CONFIG" apply -f "$variables" --namespace "$NAME_SPACE"
else
    echo "$variables does not exist."
fi

echo "[6/6] Install airflow through helm"
helm upgrade --install airflow apache-airflow/airflow --namespace "$NAME_SPACE" -f "${values}" --debug


#!/bin/bash

REGISTRY='dev-docker.seegene.com'
DOCKER_USERNAME="insilico"
DOCKER_PASSWORD="qwer1234"

NAMESPACE="spark"
SERVICE_ACCOUNT="spark-sa"
ROLE_NAME="spark-role"
ROLE_BINDING_NAME="spark-role-binding"
SECRET_NAME="docker-registry-secret"

# Create the namespace
kubectl create namespace ${NAMESPACE}

# Create the ServiceAccount
kubectl create serviceaccount ${SERVICE_ACCOUNT} -n ${NAMESPACE}

# Create the ClusterRole
kubectl create clusterrole ${ROLE_NAME} --verb=create,get,watch,list,delete --resource=pods,services,configmaps --namespace=${NAMESPACE}

# Create the ClusterRoleBinding
kubectl create clusterrolebinding ${ROLE_BINDING_NAME} --clusterrole=${ROLE_NAME} --serviceaccount=${NAMESPACE}:${SERVICE_ACCOUNT}

# Create the Registry Secret
kubectl create secret docker-registry ${SECRET_NAME} --docker-server=https://${REGISTRY} --docker-username=${DOCKER_USERNAME} --docker-password=${DOCKER_PASSWORD} -n ${NAMESPACE}

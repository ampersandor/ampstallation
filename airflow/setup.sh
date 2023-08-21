#!/bin/bash

kubectl create namespace airflow

kubectl create secret generic airflow-webserver-secret -n airflow --from-literal="webserver-secret-key=$(python3 -c 'import secrets; print(secrets.token_hex(16))')"


helm upgrade --install airflow apache-airflow/airflow --namespace airflow --create-namespace -f values.yaml --debug

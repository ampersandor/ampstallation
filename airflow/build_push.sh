#!/bin/bash

#registry='docker.seegene.com'
registry='docker-registry:31000'

docker build -t ${registry}/airflow-worker:latest -f Dockerfile.worker .

docker push ${registry}/airflow-worker:latest

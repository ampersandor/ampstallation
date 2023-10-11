#!/bin/bash
NAMESPACE="spark"


kubectl apply -f jupyter-deployment.yaml -n ${NAMESPACE}

#!/bin/bash


./deploy-apply-pvc-glusterfs.sh

./create-secret.sh

./deploy-apply-kustomize.sh
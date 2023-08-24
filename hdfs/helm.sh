#!/bin/bash

helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com

helm dependency build charts/hdfs-k8s

helm install -n insilico-hdfs charts/hdfs-k8s

#!/bin/bash

k8s_host=10.12.168.200
k8s_port=6443
k8s_api='rancher.seegene.com/k8s/clusters/c-94r7g'

cd spark-3.4.0-bin-hadoop3 

./bin/spark-submit \
    --master k8s://https://${k8s_api} \
    --deploy-mode cluster \
    --name spark-pi \
    --class org.apache.spark.examples.SparkPi \
    --conf spark.kubernetes.namespace=spark \
    --conf spark.executor.instances=5 \
    --conf spark.kubernetes.container.image=docker.seegene.com/spark-py:latest \
    --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark \
    --conf spark.kubernetes.container.image.pullSecrets=insilico-registry \
    local:///opt/spark/examples/jars/spark-examples_2.12-3.4.0.jar 10


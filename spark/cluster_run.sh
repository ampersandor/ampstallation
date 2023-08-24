#!/bin/bash

k8s_api=$(kubectl config view --minify -o jsonpath="{.clusters[0].cluster.server}")
echo ${k8s_api}
cd spark-3.4.0-bin-hadoop3 

./bin/spark-submit \
    --master k8s://${k8s_api} \
    --deploy-mode cluster \
    --name spark-pi \
    --class org.apache.spark.examples.SparkPi \
    --conf spark.kubernetes.namespace=spark \
    --conf spark.executor.instances=5 \
    --conf spark.kubernetes.container.image=docker.seegene.com/spark-py:latest \
    --conf spark.kubernetes.authenticate.driver.serviceAccountName=spark \
    --conf spark.kubernetes.container.image.pullSecrets=insilico-registry \
    local:///opt/spark/examples/jars/spark-examples_2.12-3.4.0.jar 10


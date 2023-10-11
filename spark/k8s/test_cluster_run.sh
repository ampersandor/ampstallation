#!/bin/bash

REGISTRY='dev-docker.seegene.com'
SERVICE_ACCOUNT="spark-sa"
SECRET_NAME="docker-registry-secret"
NAMESPACE="spark"

K8S_API=$(kubectl config view --minify -o jsonpath="{.clusters[0].cluster.server}")
echo ${K8S_API} 

# Specify the spark and hadoop version
SPARK_VERSION="3.4.1"
HADOOP_VERSION="3"
SPARK_SRC=spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}

cd ${SPARK_SRC}

# export SPARK_HOME=$PWD

./bin/spark-submit \
    --master k8s://${K8S_API} \
    --deploy-mode cluster \
    --name spark-pi \
    --class org.apache.spark.examples.SparkPi \
    --conf spark.kubernetes.namespace=${NAMESPACE} \
    --conf spark.executor.instances=10 \
    --conf spark.kubernetes.container.image=${REGISTRY}/spark-py:${SPARK_VERSION} \
    --conf spark.kubernetes.authenticate.driver.serviceAccountName=${SERVICE_ACCOUNT} \
    --conf spark.kubernetes.container.image.pullSecrets=${SECRET_NAME} \
    local:///opt/spark/examples/jars/spark-examples_2.12-${SPARK_VERSION}.jar 10

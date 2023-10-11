#!/bin/bash

# Define your Docker Hub credentials
DOCKER_USERNAME="insilico"
DOCKER_PASSWORD="qwer1234"

# Specify the spark and hadoop version
SPARK_VERSION="3.4.1"
HADOOP_VERSION="3"
REGISTRY='dev-docker.seegene.com'
SPARK_SRC=spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}


echo "############################################# Download spark source #############################################"
if [ -d "${SPARK_SRC}" ]; then
    echo ">>> skiping...${SPARK_SRC} already exists."
else
    wget https://dlcdn.apache.org/spark/spark-${SPARK_VERSION}/${SPARK_SRC}.tgz
    tar -xvzf ./${SPARK_SRC}.tgz
    rm ${SPARK_SRC}.tgz
    echo "$SPARK_SRC downloaded."
fi

echo "############################################# Build Spark Image #############################################"
cd ${SPARK_SRC}

./bin/docker-image-tool.sh -r ${REGISTRY} -t ${SPARK_VERSION} -p ./kubernetes/dockerfiles/spark/bindings/python/Dockerfile build


echo "############################################# Push Spark Image #############################################"

# Log in to Docker Hub
echo ${DOCKER_PASSWORD} | docker login ${REGISTRY} -u ${DOCKER_USERNAME} --password-stdin

# Check if login was successful
if [ $? -eq 0 ]; then
  echo ">> Docker login successful"
  ./bin/docker-image-tool.sh -r ${REGISTRY} -t ${SPARK_VERSION} -p ./kubernetes/dockerfiles/spark/bindings/python/Dockerfile push
else
  echo ">> Docker login failed"
fi

FROM cluster-base

ARG spark_version  # will be passed through the command line in bash
ARG hadoop_version  # will be passed through the command line in bash

RUN apt-get update -y && \
    apt-get install -y curl wget && \
    curl https://archive.apache.org/dist/spark/spark-${spark_version}/spark-${spark_version}-bin-hadoop${hadoop_version}.tgz -o spark.tgz && \
    tar -xf spark.tgz && \
    mv spark-${spark_version}-bin-hadoop${hadoop_version} /usr/bin/ && \
    mkdir /usr/bin/spark-${spark_version}-bin-hadoop${hadoop_version}/logs && \
    rm spark.tgz

COPY jars/* /usr/bin/spark-${spark_version}-bin-hadoop${hadoop_version}/jars/

ENV SPARK_HOME /usr/bin/spark-${spark_version}-bin-hadoop${hadoop_version}
ENV PYSPARK_PYTHON python3

ENV SPARK_MASTER_HOST spark-master
ENV SPARK_MASTER_PORT 7077

ENV SPARK_MASTER_WEBUI_PORT=8080
ENV SPARK_WORKER_WEBUI_PORT=8081

ENV SPARK_LOG_DIR=/opt/spark/logs 
ENV SPARK_MASTER_LOG=/opt/spark/logs/spark-master.out 
ENV SPARK_WORKER_LOG=/opt/spark/logs/spark-worker.out

RUN mkdir -p $SPARK_LOG_DIR && \
    touch $SPARK_MASTER_LOG && \
    touch $SPARK_WORKER_LOG && \
    ln -sf /dev/stdout $SPARK_MASTER_LOG && \
    ln -sf /dev/stdout $SPARK_WORKER_LOG
# -- Runtime

WORKDIR ${SPARK_HOME}

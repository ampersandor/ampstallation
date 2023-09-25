FROM spark-base

ARG SPARK_MASTER_UI_PORT=8080

EXPOSE ${SPARK_MASTER_UI_PORT}
EXPOSE ${SPARK_MASTER_PORT}
CMD bin/spark-class org.apache.spark.deploy.master.Master >> logs/spark-master.out

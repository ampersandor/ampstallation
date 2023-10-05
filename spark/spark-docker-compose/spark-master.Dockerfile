FROM spark-base

EXPOSE ${SPARK_MASTER_PORT} ${SPARK_MASTER_WEBUI_PORT}
CMD bin/spark-class org.apache.spark.deploy.master.Master >> ${SPARK_MASTER_LOG}

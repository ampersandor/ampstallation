FROM spark-base

EXPOSE ${SPARK_WORKER_UI_PORT}
CMD bin/spark-class org.apache.spark.deploy.worker.Worker spark://${SPARK_MASTER_HOST}:${SPARK_MASTER_PORT} >> ${SPARK_WORKER_LOG}

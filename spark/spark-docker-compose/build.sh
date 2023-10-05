# -- Software Stack Version
SPARK_VERSION="3.3.1"
HADOOP_VERSION="3"
JUPYTERLAB_VERSION="2.1.5"
PY4J_VERSION="0.10.9.5"
JDBC_VERSION="2.1.0.19"

echo "############################################# Download driver #############################################"
extra_jars="extra_jars"
if [ -d "${extra_jars}" ]; then
    echo ">>> skiping...${extra_jars} already exists."
else
    mkdir ${extra_jars}
    wget https://s3.amazonaws.com/redshift-downloads/drivers/jdbc/${JDBC_VERSION}/redshift-jdbc42-${JDBC_VERSION}.zip
    unzip redshift-jdbc42-${JDBC_VERSION}.zip -d ${extra_jars}/
    rm redshift-jdbc42-${JDBC_VERSION}.zip
    echo "$extra_jars downloaded."
fi

spark_source="spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}"

echo "############################################# Download spark source #############################################"
if [ -d "$spark_source" ]; then
    echo ">>> skiping...$spark_source already exists."
else
    curl https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/${spark_source}.tgz -o spark.tgz
    tar -xf spark.tgz
    rm spark.tgz
    echo "$spark_source downloaded."
fi


# -- Building the Images
echo "############################################# building cluster-base #############################################"
docker build \
  -f cluster-base.Dockerfile \
  -t cluster-base .

echo "############################################# building spark-base #############################################"
docker build \
  --build-arg spark_version="${SPARK_VERSION}" \
  --build-arg hadoop_version="${HADOOP_VERSION}" \
  -f spark-base.Dockerfile \
  -t spark-base .

echo "############################################# building spark-master #############################################"
docker build \
  -f spark-master.Dockerfile \
  -t spark-master .

echo "############################################# building spark-worker #############################################"
docker build \
  -f spark-worker.Dockerfile \
  -t spark-worker .

echo "############################################# building jupyter #############################################"
docker build \
  --build-arg spark_version="${SPARK_VERSION}" \
  --build-arg jupyterlab_version="${JUPYTERLAB_VERSION}" \
  --build-arg py4j_version="${PY4J_VERSION}" \
  -f jupyterlab.Dockerfile \
  -t jupyterlab .
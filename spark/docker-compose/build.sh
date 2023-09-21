# -- Software Stack Version
SPARK_VERSION="3.0.0"
HADOOP_VERSION="2.7"
JUPYTERLAB_VERSION="2.1.5"

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
  -f jupyterlab.Dockerfile \
  -t jupyterlab .
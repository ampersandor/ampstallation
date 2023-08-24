from pyspark import SparkContext, SparkConf
from pyspark.sql import SparkSession

k8s_api = "https://rancher.seegene.com/k8s/clusters/c-94r7g"
docker_image = "docker.seegene.com/spark-py:latest"
docker_secret = "insilico-docker-registry"

namespace = "default"

sparkConf = SparkConf()
sparkConf.setMaster(f"k8s://{k8s_api}")
sparkConf.setAppName("spark_jupyter")
sparkConf.set("spark.kubernetes.container.image", docker_image)
sparkConf.set("spark.kubernetes.container.image.pullSecrets", docker_secret)
sparkConf.set("spark.kubernetes.pyspark.pythonVersion", "3")
sparkConf.set("spark.kubernetes.namespace", namespace)
sparkConf.set("spark.executor.instances", "1")
sparkConf.set("spark.executor.cores", "1")
sparkConf.set("spark.driver.memory", "512m")
sparkConf.set("spark.executor.memory", "512m")
sparkConf.set("spark.kubernetes.authenticate.driver.serviceAccountName", "spark-sa")
sparkConf.set("spark.kubernetes.authenticate.serviceAccountName", "spark-sa")
sparkConf.set("spark.driver.host", "jupyter-labs.default.svc.cluster.local")
sparkConf.set("spark.driver.port", "29413")

sparkConf.set("spark.driver.bindAddress", "0.0.0.0")


# sparkConf.set("spark.ui.reverseProxy", "true")
# sparkConf.set("spark.driver.port", "0")  # Let the system choose an available port
# sparkConf.set("spark.driver.blockManager.port", "4444")  # Specify the port you want to use
spark = SparkSession.builder.config(conf=sparkConf).getOrCreate()
sc = spark.sparkContext
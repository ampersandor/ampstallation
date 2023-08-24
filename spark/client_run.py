from pyspark import SparkContext, SparkConf
from pyspark.sql import SparkSession

k8s_api = "https://rancher.seegene.com/k8s/clusters/c-94r7g"
docker_image = "docker.seegene.com/spark-py:latest"
docker_secret = "insilico-registry"

namespace = "spark"


sparkConf = SparkConf()
sparkConf.setMaster(f"k8s://{k8s_api}")
sparkConf.setAppName("spark")
sparkConf.set("spark.kubernetes.container.image", docker_image)
sparkConf.set("spark.kubernetes.container.image.pullSecrets", docker_secret)
sparkConf.set("spark.kubernetes.pyspark.pythonVersion", "3")
# sparkConf.set("spark.kubernetes.driver.secrets.spark-sa", "/etc/secrets")
# sparkConf.set("spark.kubernetes.executor.secrets.spark-sa", "/etc/secrets")
sparkConf.set("spark.kubernetes.authenticate.caCertFile", "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt")
sparkConf.set("spark.kubernetes.authenticate.oauthTokenFile", "/var/run/secrets/kubernetes.io/serviceaccount/token")

sparkConf.set("spark.kubernetes.namespace", namespace)
sparkConf.set("spark.executor.instances", "1")
sparkConf.set("spark.executor.cores", "1")
sparkConf.set("spark.driver.memory", "512m")
sparkConf.set("spark.executor.memory", "512m")
sparkConf.set("spark.kubernetes.authenticate.driver.serviceAccountName", "spark-sa")
sparkConf.set("spark.kubernetes.authenticate.serviceAccountName", "spark-sa")
sparkConf.set("spark.driver.port", "29415")
sparkConf.set("spark.driver.host", "jupyter-labs.spark.svc.cluster.local")
spark = SparkSession.builder.config(conf=sparkConf).getOrCreate()
sc = spark.sparkContext



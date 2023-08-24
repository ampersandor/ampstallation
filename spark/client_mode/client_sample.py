from pyspark import SparkContext, SparkConf
from pyspark.sql import SparkSession

k8s_api = "https://kubernetes.default:443"
docker_image = "docker.seegene.com/spark-py:latest"
docker_secret = "insilico-registry"

namespace = "spark"


sparkConf = SparkConf()
sparkConf.setMaster(f"k8s://{k8s_api}")
sparkConf.setAppName("spark")
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
sparkConf.set("spark.driver.port", "29415")
sparkConf.set("spark.driver.host", "jupyter-labs.spark.svc.cluster.local")
spark = SparkSession.builder.config(conf=sparkConf).getOrCreate()
sc = spark.sparkContext


data = [('James','','Smith','1991-04-01','M',3000),
  ('Michael','Rose','','2000-05-19','M',4000),
  ('Robert','','Williams','1978-09-05','M',4000),
  ('Maria','Anne','Jones','1967-12-01','F',4000),
  ('Jen','Mary','Brown','1980-02-17','F',-1)
]

columns = ["firstname","middlename","lastname","dob","gender","salary"]
df = spark.createDataFrame(data=data, schema = columns)

df.show()

mkdir my-spark-py && cd my-spark-py

wget -qO- http://apache.mirrors.hoobly.com/spark/spark-3.0.0-preview2/spark-3.0.0-preview2-bin-hadoop2.7.tgz | tar -xzf -

cp spark-3.0.0-preview2-bin-hadoop2.7/jars/kubernetes*jar . && rm -f spark-3.0.0-preview2/spark-3.0.0-preview2-bin-hadoop2.7.tgz

cat << EOF > Dockerfile
FROM docker.seegen.com/spark-py:latest
COPY *.jar /opt/spark/jars/
RUN rm /opt/spark/jars/kubernetes-*-4.1.2.jar
EOF

docker build --rm -t docker.seegen.com/spark-py:latest .
FROM cluster-base

ARG spark_version
ARG py4j_version
ARG jupyterlab_version

RUN pip3 install wget pyspark==${spark_version} 
RUN pip3 install jupyterlab==${jupyterlab_version}
RUN pip3 install py4j==${py4j_version}

EXPOSE 8888 4040
COPY jars /jars
WORKDIR ${SHARED_WORKSPACE}
CMD jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token=

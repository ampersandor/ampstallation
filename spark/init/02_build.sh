#!/bin/bash

registry='docker.seegene.com'

cd spark-3.4.0-bin-hadoop3

./bin/docker-image-tool.sh -r ${registry} -t latest -p ./kubernetes/dockerfiles/spark/bindings/python/Dockerfile build

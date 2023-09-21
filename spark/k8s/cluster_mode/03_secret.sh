#!/bin/bash

kubectl create secret docker-registry insilico-registry --docker-server=https://docker.seegene.com --docker-username=insilico --docker-password="qwer1234" -n spark

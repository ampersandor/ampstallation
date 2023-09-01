#!/bin/bash

k8s_ip=$(kubectl -n kube-system get po -o=jsonpath="{.items[0].status.hostIP}")


mkdir certs && mkdir auth

openssl req -x509 -newkey rsa:4096 -days 365 -nodes -sha256 -keyout certs/tls.key -out certs/tls.crt -subj "/CN=docker-registry" -addext "subjectAltName = DNS:docker-registry"

docker run --rm --entrypoint htpasswd registry:2.6.2 -Bbn insilico qwer1234 > auth/htpasswd

kubectl create secret tls certs-secret --cert=$PWD/certs/tls.crt --key=$PWD/certs/tls.key --namespace docker

kubectl create secret generic auth-secret --from-file=$PWD/auth/htpasswd --namespace docker

echo "Make sure to execute following 3 lines on your local machine \nIf you want to push docker image to docker-registry"

echo "sudo echo \"${k8s_ip} docker-registry\" >> /etc/hosts"

echo "suod mkdir /etc/docker/certs.d/docker-registry:31000"

echo "sudo cp ${PWD}/certs/tls.crt /etc/docker/certs.d/docker-registry:31000/ca.crt"
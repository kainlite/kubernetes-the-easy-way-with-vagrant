#!/usr/bin/env bash

source ./set-environment.sh

kubectl create secret generic kubernetes-the-hard-way \
  --from-literal="mykey=mydata"

sudo ETCDCTL_API=3 etcdctl get \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/ca.pem \
  --cert=/etc/etcd/kubernetes.pem \
  --key=/etc/etcd/kubernetes-key.pem\
  /registry/secrets/default/kubernetes-the-hard-way | hexdump -C

kubectl create deployment nginx --image=nginx
kubectl get pods -l app=nginx

POD_NAME=$(kubectl get pods -l app=nginx -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward $POD_NAME 8080:80 &

curl --head http://127.0.0.1:8080

kubectl logs $POD_NAME

kubectl exec -ti $POD_NAME -- nginx -v

kubectl expose deployment nginx --port 80 --type NodePort

NODE_PORT=$(kubectl get svc nginx \
  --output=jsonpath='{range .spec.ports[0]}{.nodePort}')

curl -I http://${KUBERNETES_PUBLIC_ADDRESS}:${NODE_PORT}

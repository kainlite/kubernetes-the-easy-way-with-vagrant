#!/usr/bin/env bash

kubectl apply -f https://storage.googleapis.com/kubernetes-the-hard-way/coredns-1.7.0.yaml

kubectl get pods -l k8s-app=kube-dns -n kube-system

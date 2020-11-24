#!/usr/bin/env bash

export INTERNAL_IP=`ifconfig | grep "inet 10.20" | awk '{ print $2 }'`
export KUBERNETES_PUBLIC_ADDRESS="10.20.0.100"
export KUBERNETES_HOSTNAMES="kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.svc.cluster.local"
export POD_CIDR="10.200.0.0/16"

declare -A EXTERNAL_IP

EXTERNAL_IP=( ["controller-0"]="10.20.0.100" ["controller-1"]="10.20.0.101" ["controller-2"]="10.20.0.102" ["worker-0"]="10.20.0.200" ["worker-1"]="10.20.0.201" ["worker-2"]="10.20.0.202")

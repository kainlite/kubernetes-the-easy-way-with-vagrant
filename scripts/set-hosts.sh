#!/usr/bin/env bash

# Update /etc/hosts about other hosts
cat >> /etc/hosts <<EOF
10.20.0.100  controller-0
10.20.0.101  controller-1
10.20.0.102  controller-2
10.20.0.200  worker-0
10.20.0.201  worker-1
10.20.0.202  worker-2
EOF

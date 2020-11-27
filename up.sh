#!/usr/bin/env bash

. scripts/set-environment.sh

rm -f certs/id_rsa certs/id_rsa.pub
ssh-keygen -f ./certs/id_rsa -t rsa -q -N ""

sed 's/config.ssh.username = "root"/# config.ssh.username = "root"/' -i Vagrantfile
sed 's/config.ssh.private_key_path = "certs\/id_rsa"/# config.ssh.private_key_path = "certs\/id_rsa"/' -i Vagrantfile

vagrant up --provider virtualbox --no-provision

echo "Waiting for the machines to be ready and to finish loading, etc"
sleep 60

for node in "${!EXTERNAL_IP[@]}"; do
    echo "Starting with node: ${node} and IP: ${EXTERNAL_IP[$node]}"

    for n in "${!EXTERNAL_IP[@]}"; do
        vagrant ssh ${node} -c "echo ${EXTERNAL_IP[$n]} $n | sudo tee -a /etc/hosts"
        vagrant ssh ${node} -c "ssh-keyscan -H ${n} | sudo tee -a /root/.ssh/known_hosts"
    done

    vagrant ssh ${node} -c "sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config"
    vagrant ssh ${node} -c "sudo service ssh restart"
    vagrant ssh ${node} -c "sudo cp /vagrant/certs/id_rsa /root/.ssh/"
    vagrant ssh ${node} -c "sudo cp /vagrant/certs/id_rsa.pub /root/.ssh/authorized_keys"
done

sleep 10
sed 's/# config.ssh.username = "root"/config.ssh.username = "root"/' -i Vagrantfile
sed 's/# config.ssh.private_key_path = "certs\/id_rsa"/config.ssh.private_key_path = "certs\/id_rsa"/' -i Vagrantfile

vagrant provision

echo "Waiting for the provisioning to be completed and to processes to start, etc"
sleep 60

# ETCD
for i in `seq 0 2`; do
    vagrant ssh controller-${i} -c "/vagrant/scripts/bootstrap-etcd.sh" &
done

wait

echo "Waiting for the ETCD to be started"
sleep 60

# Control plane
for i in `seq 0 2`; do
    vagrant ssh controller-${i} -c "/vagrant/scripts/bootstrap-control-plane.sh"
    vagrant ssh controller-${i} -c "/vagrant/scripts/create-cluster-permissions.sh"
done

echo "Waiting for the control-plane to be started"
sleep 60

# Workers
for i in `seq 0 2`; do
    vagrant ssh worker-${i} -c "/vagrant/scripts/bootstrap-worker.sh"
done

echo '######################## WAITING TILL ALL NODES ARE READY ########################'
sleep 60
chmod 400 certs/id_rsa
echo '######################## ALL DONE ########################'

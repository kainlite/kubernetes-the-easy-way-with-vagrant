#!/usr/bin/env bash

. scripts/set-environment.sh

VAGRANT_SCP=$(vagrant plugin list | grep -c vagrant-scp)

if [ $VAGRANT_SCP == "0" ]; then
    vagrant plugin install vagrant-scp
fi

# vagrant up --provider virtualbox --no-provision

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

vagrant provision

echo '######################## WAITING TILL ALL NODES ARE READY ########################'
sleep 60
chmod 400 certs/id_rsa
echo '######################## ALL DONE ########################'

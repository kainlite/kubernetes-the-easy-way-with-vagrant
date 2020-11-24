NODES_RANGE= "10.20.0"
POD_NW_CIDR = "10.244.0.0/16"

Vagrant.configure("2") do |config|
    config.vm.box = "ubuntu/bionic64"
    config.vm.box_check_update = false
    config.ssh.username = "root"
    config.ssh.private_key_path = "certs/id_rsa"
    config.ssh.path = "/root"

    (0..2).each do |n|
        config.vm.define "controller-#{n}" do |node|
            node.vm.provider "virtualbox" do |vb|
                vb.name = "controller-#{n}"
                vb.memory = 1024
                vb.cpus = 2

                vb.customize [
                    "modifyvm", :id, "--uartmode1", "file",
                    File.join(Dir.pwd, "tmp/controller-#{n}.log")
                ]
            end

            node.vm.hostname = "controller-#{n}"
            node.vm.network :private_network, ip: "#{NODES_RANGE}.10#{n}"

            node.vm.provision "set-hosts", :type => "shell", :path => "scripts/set-hosts.sh" do |s|
                s.args = ["enp0s8"]
            end

            node.vm.provision "update-dns", type: "shell", :path => "scripts/update-dns.sh"
            node.vm.provision "install-base-tools", type: "shell", :path => "scripts/install-base-tools.sh"
            node.vm.provision "install-controller-tools", type: "shell", :path => "scripts/install-controller-tools.sh"
            node.vm.provision "set-environment", type: "shell", :path => "scripts/set-environment.sh"
            if n == 0
                node.vm.provision "create-a-gazillion-certificates", type: "shell", :path => "scripts/create-certificates.sh"
                node.vm.provision "create-a-gazillion-kubeconfigs", type: "shell", :path => "scripts/create-kubeconfigs.sh"
                node.vm.provision "encryption-config", type: "shell", :path => "scripts/encryption-config.sh"
            end
            node.vm.provision "bootstrap-etcd", type: "shell", :path => "scripts/bootstrap-etcd.sh"
            node.vm.provision "bootstrap-control-plane", type: "shell", :path => "scripts/bootstrap-control-plane.sh"
            node.vm.provision "bootstrap-control-plane", type: "shell", :path => "scripts/create-cluster-permissions.sh"
        end
    end

    (0..2).each do |n|
        config.vm.define "worker-#{n}" do |node|
            node.vm.provider "virtualbox" do |vb|
                vb.name = "worker-#{n}"
                vb.memory = 2048
                vb.cpus = 1

                vb.customize [
                    "modifyvm", :id, "--uartmode1", "file",
                    File.join(Dir.pwd, "tmp/worker-#{n}.log")
                ]
            end

            node.vm.hostname = "worker-#{n}"
            node.vm.network :private_network, ip: "#{NODES_RANGE}.20#{n}"

            node.vm.provision "set-hosts", :type => "shell", :path => "scripts/set-hosts.sh" do |s|
                s.args = ["enp0s8"]
            end

            node.vm.provision 'shell', inline: "cat /vagrant/certs/id_rsa.pub >> /root/.ssh/authorized_keys"
            node.vm.provision "update-dns", type: "shell", :path => "scripts/update-dns.sh"
            node.vm.provision "install-base-tools", type: "shell", :path => "scripts/install-base-tools.sh"
            node.vm.provision "install-worker-tools", type: "shell", :path => "scripts/install-worker-tools.sh"
            node.vm.provision "set-environment", type: "shell", :path => "scripts/set-environment.sh"
            node.vm.provision "bootstrap-worker", type: "shell", :path => "scripts/bootstrap-worker.sh"
        end
    end
end

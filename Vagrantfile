# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_NO_PARALLEL'] = 'yes'

Vagrant.configure("2") do |config|

  config.vm.define :servidorUbuntu do |servidorUbuntu|
    servidorUbuntu.vm.box = "ubuntu/bionic64"
    servidorUbuntu.vm.network :private_network, ip: "172.42.42.101"
    servidorUbuntu.vm.hostname = "servidorUbuntu"
    servidorUbuntu.vm.provider "virtualbox" do |v|
     v.name = "servidorUbuntu"
     v.memory = 1024
     v.cpus =1
    end
  end

  config.vm.define :clienteUbuntu do |clienteUbuntu|
    clienteUbuntu.vm.box = "ubuntu/bionic64"
    clienteUbuntu.vm.network :private_network, ip: "172.42.42.102"
    clienteUbuntu.vm.hostname = "clienteUbuntu"
    clienteUbuntu.vm.provider "virtualbox" do |v1|
     v1.name = "clienteUbuntu"
     v1.memory = 1024
     v1.cpus =1
    end
  end

  config.vm.define :clienteUbuntu2 do |clienteUbuntu2|
    clienteUbuntu2.vm.box = "ubuntu/bionic64"
    clienteUbuntu2.vm.network :private_network, ip: "172.42.42.103"
    # clienteUbuntu2.vm.provision "shell", path: "script.sh"
    clienteUbuntu2.vm.hostname = "clienteUbuntu2"
    clienteUbuntu2.vm.provider "virtualbox" do |v2|
     v2.name = "clienteUbuntu2"
     v2.memory = 1024
     v2.cpus =1
    end
  end
end


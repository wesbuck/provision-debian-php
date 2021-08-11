# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  
    # Box Settings
    config.vm.box = "generic/debian10"
  
    # Network Settings
    config.vm.network "forwarded_port", guest: 22, host: 2209         ## SSH
    config.vm.network "forwarded_port", guest: 3306, host: 3309       ## MySQL
    config.vm.network "private_network", ip: "192.168.33.10"
  
    # Folder Settings
    config.vm.synced_folder "webroot", "/var/www/html"
  
    # Provider Settings
    config.vm.provider "virtualbox" do |vb|
      # vb.name = ""
      vb.memory = 2048
      vb.cpus = 2
    end
  
    # Provision Settings
    config.vm.provision "shell", path: "provisions.sh"
    config.vm.provision "file", source: ".gitconfig", destination: ".gitconfig"
  
  end
  
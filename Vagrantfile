# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "coneda/debian7"
  config.vm.box_url = "http://download.coneda.net/coneda_debian7.box"

  config.vm.provision :shell, path: "deploy/vagrant.sh", args: "install_standalone"
  config.vm.provision :shell, path: "deploy/vagrant.sh", args: "install_requirements"
  config.vm.provision :shell, path: "deploy/vagrant.sh", args: "install_deb"

  config.vm.network :forwarded_port, host: 8080, guest: 80

  config.vm.provider "virtualbox" do |vb|
    vb.name = "kor"
    # Don't boot with headless mode
    # vb.gui = true
  
    # Use VBoxManage to customize the VM. For example to change memory:
    vb.customize ["modifyvm", :id, "--memory", "2048"]
  end

end

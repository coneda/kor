# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.define "kor.base" do |base|
    base.vm.box = "coneda/debian7"
    base.vm.box_url = "http://download.coneda.net/coneda_debian7.box"

    base.vm.provision :shell, path: "deploy/vagrant.sh", args: "install_standalone"
    base.vm.provision :shell, path: "deploy/vagrant.sh", args: "install_requirements"

    base.vm.provider "virtualbox" do |vbox|
      vbox.name = "kor.base"
      vbox.customize ["modifyvm", :id, "--memory", "2048"]
    end
  end

  config.vm.define "kor", :primary => true do |kor|
    kor.vm.box = "coneda/debian7.kor"
    kor.vm.box_url = "http://download.coneda.net/coneda_debian7.kor.box"

    kor.vm.provision :shell, path: "deploy/vagrant.sh", args: "install_deb"

    kor.vm.network :forwarded_port, host: 8080, guest: 80

    kor.vm.provider "virtualbox" do |vbox|
      vbox.name = "kor"
      vbox.customize ["modifyvm", :id, "--memory", "2048"]
    end
  end

end

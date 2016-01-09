# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.ssh.insert_key = false

  pe = {
    "VERSION" => ENV["VERSION"] || File.read("config/version.txt")
  }

  config.vm.define "dev", :primary => true do |c|
    c.vm.box = "ubuntu/trusty64"

    c.vm.network :forwarded_port, host: 3000, guest: 3000
    c.vm.provider "virtualbox" do |vbox|
      vbox.name = "kor.dev"
      vbox.customize ["modifyvm", :id, "--memory", "2048"]
      vbox.customize ["modifyvm", :id, "--cpus", "2"]
    end

    c.vm.provision :shell, path: "deploy/vagrant.sh", args: "system_updates"
    c.vm.provision :shell, path: "deploy/vagrant.sh", args: "install_dev_requirements"
    c.vm.provision :shell, path: "deploy/vagrant.sh", args: "install_elasticsearch"
    c.vm.provision :shell, path: "deploy/vagrant.sh", args: "install_mysql"
    c.vm.provision :shell, path: "deploy/vagrant.sh", args: "install_rbenv"
    c.vm.provision :shell, path: "deploy/vagrant.sh", args: "configure_dev", privileged: false
  end

  config.vm.define "prod", autostart: false do |c|
    c.vm.box = "ubuntu/trusty64"

    c.vm.network :forwarded_port, host: 8080, guest: 80
    c.vm.provider "virtualbox" do |vbox|
      vbox.name = "kor.prod"
      vbox.customize ["modifyvm", :id, "--memory", "2048"]
      vbox.customize ["modifyvm", :id, "--cpus", "2"]
    end

    c.vm.provision :shell, path: "deploy/vagrant.sh", args: "system_updates"
    c.vm.provision :shell, path: "deploy/vagrant.sh", args: "install_prod_requirements"
    c.vm.provision :shell, path: "deploy/vagrant.sh", args: "install_elasticsearch"
    c.vm.provision :shell, path: "deploy/vagrant.sh", args: "install_mysql"
    c.vm.provision :shell, path: "deploy/vagrant.sh", args: "install_prod", privileged: false, env: pe
    c.vm.provision :shell, path: "deploy/vagrant.sh", args: "install_rbenv"
    c.vm.provision :shell, path: "deploy/vagrant.sh", args: "configure_prod", privileged: false
    c.vm.provision :shell, path: "deploy/vagrant.sh", args: "clean"
  end

end

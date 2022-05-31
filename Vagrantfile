# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = '2'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vagrant.plugins = ['vagrant-vbguest']
  config.ssh.insert_key = false

  pe = {
    'VERSION' => ENV['VERSION'] || `git rev-parse --abbrev-ref HEAD`
  }

  config.vm.define "dev.v4.2", primary: true do |c|
    c.vm.box = 'generic/debian11'

    if RUBY_PLATFORM.match(/darwin/)
      c.vm.synced_folder ".", "/vagrant", type: "nfs"
      c.vm.network "private_network", type: "dhcp"
    else
      c.vm.synced_folder '.', '/vagrant', type: 'virtualbox'
    end

    c.vm.network :forwarded_port, host: 3000, guest: 3000
    c.vm.network :forwarded_port, host: 3306, guest: 3306
    c.vm.network :forwarded_port, host: 9200, guest: 9200

    c.vm.provider "virtualbox" do |vbox|
      vbox.name = "kor.v4.0.dev"
      vbox.customize ["modifyvm", :id, "--memory", "2048"]
      vbox.customize ["modifyvm", :id, "--cpus", "2"]
    end

    c.vm.provision :shell, path: "deploy/vagrant.sh", args: "system_updates"
    c.vm.provision :shell, path: "deploy/vagrant.sh", args: "install_dev_requirements"
    c.vm.provision :shell, path: "deploy/vagrant.sh", args: "install_elasticsearch"
    c.vm.provision :shell, path: "deploy/vagrant.sh", args: "elasticsearch_dev"
    c.vm.provision :shell, path: "deploy/vagrant.sh", args: "install_mysql"
    c.vm.provision :shell, path: "deploy/vagrant.sh", args: "mysql_dev"
    c.vm.provision :shell, path: "deploy/vagrant.sh", args: "install_nvm", env: {'NODE_VERSION' => '12.22.0'}
    c.vm.provision :shell, path: "deploy/vagrant.sh", args: "install_rbenv", env: {'RUBY_VERSION' => '2.7.6'}
    c.vm.provision :shell, path: "deploy/vagrant.sh", args: "configure_dev", privileged: false
  end
end

# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = '2'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vagrant.plugins = ['vagrant-vbguest']
  config.ssh.insert_key = false
  config.vm.box = 'bento/ubuntu-16.04'

  pe = {
    'VERSION' => ENV['VERSION'] || `git rev-parse --abbrev-ref HEAD`
  }

  config.vm.define 'manual', autostart: false do |c|
    c.ssh.insert_key = true
    c.vm.box = 'debian/stretch64'
    c.vm.synced_folder '.', '/vagrant', type: 'virtualbox'
    c.vm.network :forwarded_port, host: 8080, guest: 80
    c.vm.provider "virtualbox" do |vbox|
      vbox.name = "kor.manual"
      vbox.customize ["modifyvm", :id, "--memory", "2048"]
      vbox.customize ["modifyvm", :id, "--cpus", "2"]
    end
  end

  config.vm.define "dev.v4.0", primary: true do |c|
    c.vm.box = 'generic/debian10'

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
    c.vm.provision :shell, path: "deploy/vagrant.sh", args: "install_rbenv", env: {'RUBY_VERSION' => '2.6.7'}
    c.vm.provision :shell, path: "deploy/vagrant.sh", args: "configure_dev", privileged: false
  end

  config.vm.define "prod", autostart: false do |c|
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

  config.vm.define "bare", autostart: false do |c|
    if RUBY_PLATFORM.match(/darwin/)
      c.vm.synced_folder ".", "/vagrant", type: "nfs"
      c.vm.network "private_network", type: "dhcp"
    else
      c.vm.synced_folder '.', '/vagrant', type: 'virtualbox'
    end
    c.vm.network :forwarded_port, host: 8080, guest: 80
    c.vm.provider "virtualbox" do |vbox|
      vbox.name = "kor.bare"
      vbox.customize ["modifyvm", :id, "--memory", "2048"]
      vbox.customize ["modifyvm", :id, "--cpus", "2"]
    end

    c.vm.provision :shell, path: "deploy/vagrant.sh", args: "system_updates"
    c.vm.provision :shell, path: "deploy/vagrant.sh", args: "install_prod_requirements"
    c.vm.provision :shell, path: "deploy/vagrant.sh", args: "install_elasticsearch"
    c.vm.provision :shell, path: "deploy/vagrant.sh", args: "install_mysql"
    c.vm.provision :shell, path: "deploy/vagrant.sh", args: "clean"

    c.vm.provision :shell, inline: <<-SHELL
      mkdir -p /opt/kor
      chown vagrant. /opt/kor
      apt-get install ruby ruby-dev
      gem install bundler
    SHELL
  end

  config.vm.define 'centos7', autostart: false do |c|
    c.vm.box = 'centos/7'
    # c.ssh.pty = true

    if RUBY_PLATFORM.match(/darwin/)
      config.vm.synced_folder ".", "/vagrant", type: "nfs"
      config.vm.network "private_network", type: "dhcp"
    else
      c.vm.synced_folder '.', '/vagrant', type: 'virtualbox'
    end
    c.vm.network :forwarded_port, host: 3000, guest: 3000, host_ip: '127.0.0.1'
    c.vm.network :forwarded_port, host: 3306, guest: 3306, host_ip: '127.0.0.1'
    c.vm.network :forwarded_port, host: 9200, guest: 9200, host_ip: '127.0.0.1'

    c.vm.provider "virtualbox" do |vbox|
      vbox.name = "kor.centos7"
      vbox.customize ["modifyvm", :id, "--memory", "2048"]
      vbox.customize ["modifyvm", :id, "--cpus", "2"]
    end

    c.vm.provision :shell, path: "deploy/vagrant.centos.sh", args: "install_part1"
    c.vm.provision :shell, path: "deploy/vagrant.centos.sh", args: "install_part2", privileged: false
    c.vm.provision :shell, path: "deploy/vagrant.centos.sh", args: "install_part3"
  end
end

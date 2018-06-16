#!/bin/bash -e

SCRIPT=$0
COMMAND=$1

function install_part1 {
  yum upgrade -y
  yum -y install \
    git gcc gcc-c++ make mariadb-libs mariadb-devel openssl-libs ruby-devel \
    libxml2-devel libxslt-devel ImageMagick zip mariadb-server patch autoconf \
    automake bison libffi-devel libtool patch readline-devel sqlite-devel

  sudo systemctl enable mariadb
  sudo systemctl start mariadb

  mysqladmin -u root password 'root'

  # download rvm installer script
  curl -sSL https://get.rvm.io > /root/rvm.sh
  chmod +x /root/rvm.sh
}

function install_part2 {
  # the script needs to be run with the sudo prefix, not as root
  sudo /root/rvm.sh
  sudo usermod -a -G rvm vagrant
}

function install_part3 {
  # we have to create a login subshell so that the user vagrant's groups are
  # reloaded
  su -l -c "$SCRIPT do_install_part3" vagrant
}

function do_install_part3 {
  source /usr/local/rvm/scripts/rvm
  rvm install 2.4.3
  rvm alias create default 2.4.3
  rvm use 2.4.3

  gem install bundler
  cd /vagrant
  bundle install
  bundle exec rake db:setup
}


$COMMAND

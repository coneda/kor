#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

function install_standalone {
  apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
  echo 'deb http://downloads-distro.mongodb.org/repo/debian-sysvinit dist 10gen' | tee /etc/apt/sources.list.d/mongodb.list

  debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
  debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'

  apt-get update
  apt-get install -y mysql-server mongodb-10gen

  echo "GRANT ALL ON kor.* TO 'kor'@'localhost' IDENTIFIED BY 'kor';" | mysql -u root -proot
}

function install_requirements {
  apt-get update
  apt-get upgrade -y
  apt-get install -y git-core build-essential ruby apache2 apache2-prefork-dev libmysqlclient-dev libcurl4-openssl-dev ruby-dev libxml2-dev libxslt-dev openjdk-7-jre imagemagick ffmpeg libapache2-mod-passenger zip
}

function install_deb {
  export VERSION=`cat /vagrant/config/version.txt 2> /dev/null`
  export DEB_FILENAME="coneda-kor.v$VERSION.deb"
  
  dpkg -i /vagrant/deploy/build/$DEB_FILENAME
 
  su -c "cd /opt/kor/current ; RAILS_ENV=production bundle exec rake db:setup" kor
  su -c "cd /opt/kor/current ; bundle exec rake assets:precompile" kor
  su -c "touch /opt/kor/current/tmp/restart.txt" kor

  /etc/init.d/sunspot start
  /etc/init.d/delayed_job start
}

function appliance {
  export VERSION=`cat config/version.txt`
  export OVA_FILENAME="deploy/build/coneda-kor.v$VERSION.ova"

  vagrant halt kor

  VBoxManage export kor \
    --vsys 0 \
    --product "ConedaKOR" \
    --producturl "http://coneda.net" \
    --vendor "Coneda UG" \
    --vendorurl "http://coneda.net" \
    --version "$VERSION" \
    --options manifest \
    --output $OVA_FILENAME

  chmod 644 $OVA_FILENAME
}

function checksums {
  cd deploy/build

  for FILE in `find . -type f -not -iname "*.md5"` ; do
    md5sum $FILE > $FILE.md5
  done   
}

$1
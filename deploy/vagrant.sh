#!/bin/bash -e

export DEBIAN_FRONTEND=noninteractive

function system_updates {
  apt-get update
  apt-get dist-upgrade -y
  apt-get clean
}

function install_requirements {
  apt-get install -y \
    git-core build-essential libmysqlclient-dev libcurl4-openssl-dev ruby-dev \
    libxml2-dev libxslt-dev imagemagick libav-tools zip
}

function install_test_requirements {
  install_requirements
  apt-get install -y phantomjs
}

function install_dev_requirements {
  install_requirements
  install_test_requirements
  apt-get install -y \
    libmysqlclient-dev imagemagick libav-tools zip openjdk-7-jre
}

function install_prod_requirements {
  install_requirements
  sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
  sudo apt-get install -y apt-transport-https ca-certificates
  sudo sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main > /etc/apt/sources.list.d/passenger.list'
  sudo apt-get update
  apt-get install -y apache2 libapache2-mod-passenger
  sudo a2enmod passenger
}

function install_elasticsearch {
  wget -qO - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | sudo apt-key add -
  echo 'deb http://packages.elasticsearch.org/elasticsearch/1.5/debian stable main' | tee /etc/apt/sources.list.d/elastic.list
  apt-get update
  apt-get install -y openjdk-7-jre elasticsearch
  update-rc.d elasticsearch defaults
  service elasticsearch start
}

function install_mysql {
  debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
  debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
  apt-get install -y mysql-server
  echo "GRANT ALL ON kor.* TO 'kor'@'localhost' IDENTIFIED BY 'kor';" | mysql -u root -proot
}

function appliance {
  export OVA_FILENAME="deploy/build/coneda-kor.$VERSION.ova"

  vagrant halt prod

  VBoxManage sharedfolder remove "kor.prod" --name "vagrant"

  VBoxManage export kor.prod \
    --vsys 0 \
    --product "ConedaKOR" \
    --producturl "https://coneda.net" \
    --vendor "Coneda UG" \
    --vendorurl "https://coneda.net" \
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

function install_rbenv {
  apt-get install -y autoconf bison build-essential libssl-dev \
    libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev \
    libffi-dev libgdbm3 libgdbm-dev git-core

  git clone https://github.com/sstephenson/rbenv.git /opt/rbenv
  git clone https://github.com/rbenv/ruby-build.git /opt/rbenv/plugins/ruby-build

  echo 'export RBENV_ROOT="/opt/rbenv"' >> /etc/profile.d/rbenv.sh
  echo 'export PATH="/opt/rbenv/bin:$PATH"' >> /etc/profile.d/rbenv.sh
  echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh

  source /etc/profile.d/rbenv.sh

  RUBY_VERSION=`cat /vagrant/.ruby-version`
  if [ -d "/opt/kor" ]; then
    RUBY_VERSION=`cat /opt/kor/.ruby-version`
  fi
  rbenv install $RUBY_VERSION
  rbenv shell $RUBY_VERSION
  gem install bundler

  chown -R vagrant. /opt/rbenv
  chmod -R g+w /opt/rbenv/shims
}

function clean {
  apt-get clean
}

function configure_dev {
  cd /vagrant
  bundle install
  rbenv rehash
  cp config/database.yml.example config/database.yml
  bundle exec rake db:drop db:setup
  bundle exec rake db:test:load
  bundle exec bin/kor index-all
}

function install_prod {
  sudo git clone /vagrant /opt/kor
  sudo chown -R vagrant. /opt/kor
  cd /opt/kor
  git checkout $VERSION
}

function configure_prod {
  export RAILS_ENV=production
  cd /opt/kor

  sudo cp /vagrant/deploy/templates/delayed_job.upstart /etc/init/kor-bg.conf
  sudo cp /vagrant/deploy/templates/apache.conf /etc/apache2/sites-available/001-kor.conf
  sudo a2dissite 000-default
  sudo a2ensite 001-kor
  sudo service apache2 restart

  sudo cp /vagrant/deploy/templates/gemrc /etc/gemrc
  sudo cp /vagrant/deploy/templates/logrotate.conf /etc/logrotate.d/kor.conf
  crontab /vagrant/deploy/templates/crontab

  bundle install --without development test --path /opt/kor/bundle
  rbenv rehash
  cp /vagrant/config/database.yml.example config/database.yml

  bundle exec rake db:drop db:setup
  bundle exec rake assets:precompile
  bundle exec bin/kor index-all

  sudo service kor-bg start
}

$1

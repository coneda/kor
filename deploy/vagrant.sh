#!/bin/bash -e

export DEBIAN_FRONTEND=noninteractive

function system_updates {
  echo "grub-pc hold" | sudo dpkg --set-selections
  
  apt-get update
  apt-get dist-upgrade -y
  apt-get clean
}

function install_requirements {
  apt-get install -y \
    git-core build-essential default-libmysqlclient-dev libcurl4-openssl-dev ruby-dev \
    libxml2-dev libxslt-dev imagemagick ffmpeg zip
}

function install_test_requirements {
  install_requirements
}

function install_dev_requirements {
  install_requirements
  install_test_requirements
  apt-get install -y \
    default-libmysqlclient-dev imagemagick ffmpeg zip default-jre chromium
}

function install_prod_requirements {
  install_requirements
  sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
  sudo apt-get install -y apt-transport-https ca-certificates
  sudo apt-get update
  apt-get install -y apache2 libapache2-mod-passenger
  sudo a2enmod passenger
}

function install_elasticsearch {
  wget -O /root/elasticsearch.deb "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.6.16.deb"
  apt-get install -y default-jre
  dpkg -i /root/elasticsearch.deb
  rm /root/elasticsearch.deb
  systemctl enable elasticsearch.service
  systemctl start elasticsearch.service
}

function elasticsearch_dev {
  sed -i -E "s/^#\s*?network.host:\s+.*$/network.host: 0.0.0.0/" /etc/elasticsearch/elasticsearch.yml
  systemctl restart elasticsearch.service
}

function install_mysql {
  debconf-set-selections <<< "mariadb-server-10.3 mariadb-server-10.3/root_password password root"
  debconf-set-selections <<< "mariadb-server-10.3 mariadb-server-10.3/root_password_again password root" 

  apt-get install -y mariadb-server
  echo "GRANT ALL ON kor.* TO 'kor'@'localhost' IDENTIFIED BY 'kor';" | mysql -u root -proot
}

function mysql_dev {
  sed -i -E "s/bind-address\s*=\s*127.0.0.1/#bind-address = 127.0.0.1/" /etc/mysql/mariadb.conf.d/50-server.cnf
  systemctl restart mariadb.service
  mysql -u root -proot -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root'"
  mysql -u root -proot -e "DELETE FROM mysql.user where User='root' AND Host='localhost'"
  mysql -u root -proot -e "FLUSH PRIVILEGES"
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
    libffi-dev libgdbm6 libgdbm-dev git-core

  git clone https://github.com/sstephenson/rbenv.git /opt/rbenv
  git clone https://github.com/rbenv/ruby-build.git /opt/rbenv/plugins/ruby-build

  echo 'export RBENV_ROOT="/opt/rbenv"' >> /etc/profile.d/rbenv.sh
  echo 'export PATH="/opt/rbenv/bin:$PATH"' >> /etc/profile.d/rbenv.sh
  echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh

  source /etc/profile.d/rbenv.sh

  rbenv install $RUBY_VERSION
  rbenv global $RUBY_VERSION
  gem install bundler

  chown -R vagrant. /opt/rbenv
  chmod -R g+w /opt/rbenv/shims
}

function install_nvm {
  git clone https://github.com/nvm-sh/nvm.git /opt/nvm
  source /opt/nvm/nvm.sh

  echo 'export NVM_DIR="/opt/nvm"' >> /etc/profile.d/nvm.sh
  echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> /etc/profile.d/nvm.sh
  echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> /etc/profile.d/nvm.sh

  source /etc/profile.d/nvm.sh
  nvm install $NODE_VERSION

  chown -R vagrant. /opt/nvm
}

function install_docker {
  apt-get update -y
  apt-get install -y docker.io docker-compose
}

function clean {
  apt-get clean
}

function configure_dev {
  cd /vagrant
  npm install -g
  bundle install
  rbenv rehash
  # cp config/database.yml.example config/database.yml
  bundle exec rake db:drop db:setup
  RAILS_ENV=test bundle exec rake db:drop db:setup
  bundle exec bin/kor index-all
}

function install_prod {
  if [ ! -d  /opt/kor ]; then
    sudo git clone /vagrant /opt/kor
  fi
  sudo chown -R vagrant. /opt/kor
  cd /opt/kor
  git checkout $VERSION
}

$1

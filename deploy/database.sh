#!/bin/bash

# Usage:
# deploy/database.sh root@192.168.0.44

BUILD_DIR=deploy/build
TARGET=$1

ROOT_PASSWORD="toor"

ssh $TARGET "apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10"
ssh $TARGET "echo 'deb http://downloads-distro.mongodb.org/repo/debian-sysvinit dist 10gen' | tee /etc/apt/sources.list.d/mongodb.list"

ssh $TARGET "debconf-set-selections <<< 'mysql-server mysql-server/root_password password $ROOT_PASSWORD'"
ssh $TARGET "debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password $ROOT_PASSWORD'"

ssh $TARGET "apt-get update"

ssh $TARGET "apt-get install -y mysql-server mongodb-10gen"
ssh $TARGET "mysql -u root -p$ROOT_PASSWORD -e \"GRANT ALL ON kor.* TO 'kor'@'localhost' IDENTIFIED BY 'kor'\" "
# ssh $TARGET "mysql -u root -p$ROOT_PASSWORD -e \"CREATE DATABASE kor CHARACTER SET 'utf8' COLLATE 'utf8_general_ci'\" "
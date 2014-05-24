#!/bin/bash

# Usage:
# deploy/build.sh root@192.168.0.44 "Debian 7 wheezy" "clean_ist"

BUILD_DIR=deploy/build
TARGET=$1

VERSION=`cat config/version.txt`
DEB_FILENAME="coneda-kor.v$VERSION.deb"

APT_CONFIG="DEBIAN_FRONTEND=noninteractive"

scp $BUILD_DIR/$DEB_FILENAME $TARGET:/usr/src
ssh $TARGET "$APT_CONFIG apt-get update"
ssh $TARGET "$APT_CONFIG apt-get upgrade -y"

# for debian wheezy
ssh $TARGET "$APT_CONFIG apt-get install -y git-core build-essential ruby apache2 apache2-prefork-dev libmysqlclient-dev libcurl4-openssl-dev ruby-dev libxml2-dev libxslt-dev openjdk-7-jre imagemagick ffmpeg libapache2-mod-passenger zip"
ssh $TARGET "dpkg -i /usr/src/$DEB_FILENAME"
ssh $TARGET -t "sh /opt/kor/current/deploy/post-install.sh"
# end debian wheezy
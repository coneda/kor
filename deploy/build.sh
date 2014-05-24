#!/bin/bash

# Usage:
# deploy/build.sh root@192.168.0.44 "Debian 7 wheezy" "clean_ist"

TARGET=$1
MACHINE=$2
SNAPSHOT=$3

deploy/debian.rb
deploy/prepare-vm.sh "$MACHINE" "$SNAPSHOT"
deploy/database.sh $TARGET
deploy/install.sh $TARGET
deploy/appliance.sh "$MACHINE"

deploy/checksums.sh
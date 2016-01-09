#!/bin/bash -e

export VERSION=$1

# Set up vm
vagrant up prod

# Extract appliance
deploy/vagrant.sh appliance

# Tear down vm
vagrant destroy -f prod

# Calculate md5 checksums
deploy/vagrant.sh checksums

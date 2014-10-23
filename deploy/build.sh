#!/bin/bash -e

# Build debian package
deploy/debian.rb

# Set up vm
vagrant up kor

# Extract appliance
deploy/vagrant.sh appliance

# Tear down vm
# vagrant destroy kor -f

# Calculate md5 checksums
deploy/vagrant.sh checksums

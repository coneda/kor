#!/bin/bash

# Build debian package
deploy/debian.rb

# Set up vm
vagrant up

# Extract appliance
deploy/vagrant.sh appliance

# Tear down vm
vagrant destroy -f

# Calculate md5 checksums
deploy/vagrant.sh checksums

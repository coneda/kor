#!/bin/bash -e

# Set up vm
vagrant up kor.base

# Extract base box
vagrant package --base "kor.base"

# Re-import the box
vagrant box remove coneda/debian7.kor
vagrant box add package.box --name coneda/debian7.kor

# Save the box
mv package.box deploy/build.boxes/coneda_debian7.kor.box

# Tear down vm
vagrant destroy kor.base -f

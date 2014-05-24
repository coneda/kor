#!/bin/bash

# Usage:
# deploy/prepare-vm.sh "Debian 7 wheezy" "clean_ist"

MACHINE=$1
SNAPSHOT=$2

if VBoxManage list runningvms | grep "$MACHINE" > /dev/null ; then
  VBoxManage controlvm "$MACHINE" poweroff

  while VBoxManage list runningvms | grep "$MACHINE" > /dev/null
  do
    sleep 1
  done
fi

VBoxManage snapshot "$MACHINE" restore "$SNAPSHOT"
VBoxManage startvm "$MACHINE" --type headless

echo "waiting 15 seconds for the machine to settle in"
sleep 15

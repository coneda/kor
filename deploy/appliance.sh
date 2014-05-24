#!/bin/bash

# Usage:
# deploy/appliance.sh "Debian 7 wheezy"

MACHINE=$1
VERSION=`cat config/version.txt`
OVA_FILENAME="deploy/build/coneda-kor.v$VERSION.ova"

VBoxManage controlvm "$MACHINE" acpipowerbutton

# Wait for machine to complete its shutdown
while VBoxManage list runningvms | grep "$MACHINE" > /dev/null
do
  sleep 1
done

rm -f $OVA_FILENAME

VBoxManage export "$MACHINE" \
  --vsys 0 \
  --product "ConedaKOR" \
  --producturl "http://coneda.net" \
  --vendor "Coneda UG" \
  --vendorurl "http://coneda.net" \
  --version "$VERSION" \
  --options manifest \
  --output $OVA_FILENAME

chmod 644 $OVA_FILENAME

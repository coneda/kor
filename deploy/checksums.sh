#!/bin/bash

# Usage:
# deploy/checksums.sh

cd deploy/build

for FILE in `find . -type f -not -iname "*.md5"` ; do
  md5sum $FILE > $FILE.md5
done
#!/bin/bash -e

DIR="widgets"
TMP="$DIR/tmp/js-build"

mkdir -p $TMP

function deps {
  uglifyjs \
    node_modules/zepto/zepto.min.js \
    node_modules/riot/riot.js \
    -o $TMP/deps.js

  cp widgets/vendor/bootstrap.min.css public/bootstrap.min.css
  cp -a node_modules/bootstrap/fonts public/
}

function tags {
  riot --colors --whitespace $DIR/tags $TMP/tags.js
}

function build {
  deps
  tags

  cat $TMP/deps.js $TMP/tags.js > public/app.js
}

function watch_tags {
  build
  onchange $DIR/tags -- ./build.sh build
}

function watch {
  parallelshell \
    "./build.sh watch_tags"
}

$1
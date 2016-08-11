#!/bin/bash -e

DIR="widgets"
TMP="$DIR/tmp/js-build"

mkdir -p $TMP

function deps {
  uglifyjs \
    node_modules/zepto/zepto.min.js \
    node_modules/riot/riot.js \
    -o $TMP/so-deps.js

  uglifyjs \
    node_modules/lockr/lockr.min.js \
    node_modules/riot-route/dist/route.min.js \
    -o $TMP/app-deps.js

  cp widgets/vendor/bootstrap.min.css public/bootstrap.min.css
  cp -a node_modules/bootstrap/fonts public/
}

function tags {
  riot --colors --whitespace $DIR/tags/standalone $TMP/so-tags.js
  riot --colors --whitespace $DIR/tags/app $TMP/app-tags.js
}

function build {
  echo "building on $(date)"

  deps
  tags

  cat $TMP/so-deps.js $TMP/so-tags.js $DIR/lib/boot.js > public/lib.js
  cat $TMP/app-deps.js $TMP/app-tags.js > public/app.js
}

function watch_tags {
  build || true
  onchange $DIR/tags $DIR/_vars.scss -- widgets/build.sh build
}

function watch {
  parallelshell \
    "widgets/build.sh watch_tags"
}

$1
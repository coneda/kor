#!/bin/bash -e

COMMAND=${1:-all}

RED="\e[0;31m"
GREEN="\e[0;32m"
BLUE="\e[0;34m"
LIGHTBLUE="\e[1;34m"
NOCOLOR="\e[0m"

mkdir -p tmp/widgets

function all {
  vendor
  lib
  tags
  css
  app
  html
  images
}

function watch {
  all || true

  parallelshell \
    "widgets/build.sh watch_vendor" \
    "widgets/build.sh watch_lib" \
    "widgets/build.sh watch_tags" \
    "widgets/build.sh watch_css" \
    "widgets/build.sh watch_app" \
    "widgets/build.sh watch_html" \
    "widgets/build.sh watch_images"
}

function server {
  cd public
  static -p 3000 -a 127.0.0.1
}

function vendor {
  log "concatenating vendor css"
  cat widgets/vendor/css/*.css > public/vendor.css

  log "copying other vendor assets"
  rsync -aL widgets/vendor/other/ public/

  log "combining vendor javascript"
  uglifyjs widgets/vendor/js/*.js -o tmp/widgets/vendor.js
}

function lib {
  log "compiling lib"
  cat \
    widgets/app.js.coffee widgets/lib/*.js.coffee | \
    node_modules/.bin/coffee -s -b -p | \
    cat - widgets/lib/*.js \
    > tmp/widgets/lib.js
}

function tags {
  log "compiling tags"
  node_modules/.bin/riot widgets/tags tmp/widgets/tags.js > /dev/null
}

function app {
  log "concatenating app"
  uglifyjs tmp/widgets/vendor.js tmp/widgets/lib.js tmp/widgets/tags.js -b -o public/app-noboot.js
  echo | cat public/app-noboot.js - widgets/boot.js > public/app.js
}

function css {
  log "compiling style sheets"
  node-sass widgets/app.scss > public/app.css
}

function html {
  log "compiling html"
  for TPL in widgets/*.html.ejs; do
    local TARGET=$(echo $TPL | sed -E "s/\.ejs$//" | sed -E "s/^widgets\///")
    widgets/build.js $TPL > public/$TARGET
  done
}

function images {
  log "copying images"
  rm -rf public/images

  if [ -d widgets/images ]; then
    cp -a widgets/images public/
  fi
}

function watch_vendor {
  onchange widgets/vendor -- widgets/build.sh vendor
}

function watch_lib {
  onchange widgets/app.js.coffee widgets/lib -- widgets/build.sh lib
}

function watch_tags {
  onchange widgets/tags widgets/styles -- widgets/build.sh tags
}

function watch_app {
  onchange \
    tmp/widgets/vendor.js tmp/widgets/lib.js tmp/widgets/tags.js \
    -- widgets/build.sh app
}

function watch_css {
  onchange widgets/app.scss widgets/styles -- widgets/build.sh css
}

function watch_html {
  onchange \
    public/app.js public/vendor.css tmp/widgets/vendor.* widgets/*.html.ejs \
    -- widgets/build.sh html
}

function watch_images {
  onchange widgets/images -- widgets/build.sh images
}

function log {
  TS=$(date +"%Y-%m-%d %H:%M:%S")
  MSG="$1"
  echo -e "$GREEN$TS: $MSG$NOCOLOR"
}


$COMMAND

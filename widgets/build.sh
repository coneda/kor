#!/bin/bash -e

COMMAND=${1:-all}

RED="\e[0;31m"
GREEN="\e[0;32m"
BLUE="\e[0;34m"
LIGHTBLUE="\e[1;34m"
NOCOLOR="\e[0m"

function all {
  vendor
  lib
  tags
  app
  html
}

function watch {
  all || true

  parallelshell \
    "widgets/build.sh watch_vendor" \
    "widgets/build.sh watch_lib" \
    "widgets/build.sh watch_tags" \
    "widgets/build.sh watch_app" \
    "widgets/build.sh watch_html"
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
  uglifyjs widgets/vendor/js/*.js -o public/vendor.js
}

function lib {
  log "compiling lib"
  cat widgets/app.js.coffee widgets/lib/* | node_modules/.bin/coffee -s -b -p > public/lib.js
}

function tags {
  log "compiling tags"
  node_modules/.bin/riot widgets/tags public/tags.js 2> /dev/null
}

function app {
  log "concatenating app"
  uglifyjs public/vendor.js public/lib.js public/tags.js -o public/app.js
}

function html {
  log "compiling html"
  for TPL in widgets/*.html.ejs; do
    local TARGET=$(echo $TPL | sed -E "s/\.ejs$//" | sed -E "s/^widgets\///")
    widgets/build.js $TPL > public/$TARGET
  done
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
  onchange public/vendor.js public/lib.js public/tags.js -- widgets/build.sh app
}

function watch_html {
  onchange public/app.js public/vendor.* widgets/*.html.ejs -- widgets/build.sh html
}

function log {
  TS=$(date +"%Y-%m-%d %H:%M:%S")
  MSG="$1"
  echo -e "$GREEN$TS: $MSG$NOCOLOR"
}


$COMMAND

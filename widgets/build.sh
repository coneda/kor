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

  npm-run-all -p \
    watch:vendor \
    watch:lib \
    watch:tags \
    watch:css \
    watch:app \
    watch:html \
    watch:images
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
  TARGET="tmp/widgets/lib.js"
  cat widgets/app.js > $TARGET
  cat widgets/lib/*.js.coffee | node_modules/.bin/coffee -s -b -p >> $TARGET
  cat widgets/lib/*.js >> $TARGET
}

function tags {
  log "compiling tags"
  node_modules/.bin/riot widgets/tags tmp/widgets/tags.js > /dev/null
}

function app {
  log "concatenating app"
  uglifyjs tmp/widgets/vendor.js tmp/widgets/lib.js tmp/widgets/tags.js -b -o public/app-noboot.js
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
  onchange widgets/app.js widgets/lib -- widgets/build.sh lib
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

function clean {
  git checkout -f public
  git clean -f -d public
}

function replace_symlinks {
  if ! [ -n "$MYWINDIR" ]; then
    # we are not on windows
    exit 0
  fi

  echo "Windows docker host, replacing symlinks"

  for SL in widgets/vendor/*/*; do
    LENGTH=$(wc -l $SL | cut -d' ' -f1)
    if [ "$LENGTH" == "0" ]; then
      TARGET=$(cat $SL)
      rm $SL
      cp -a ${TARGET//..\//} $SL
    fi
  done
}

function tocs {
  printf "dev.md:\n"
  markdown-toc docs/dev.md --no-firsth1

  printf "\n\nops.md:\n"
  markdown-toc docs/ops.md --no-firsth1

  printf "\n\napi.intro.md:\n"
  markdown-toc docs/api.intro.md --no-firsth1

  printf "\n\ndocker.md:\n"
  markdown-toc docs/docker.md --no-firsth1
}

$COMMAND


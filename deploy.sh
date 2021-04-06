#!/bin/bash

# Copyright (c) 2014 Moritz Schepp <moritz.schepp@gmail.com>
# Distributed under the GNU GPL v3. For full terms see
# http://www.gnu.org/licenses/gpl-3.0.txt

# This is a deploy script for generic apps. Modify the deploy function to suit
# your needs.

# Load user settings

. ./deploy.config.sh && $1

# Deploy

function deploy {
  if [ "$BUILD_FRONTEND" = "true" ]; then
    if ! which npm > /dev/null ; then
      echo "WARNING, npm was not found so some assets can't be compiled. As a"
      echo "fallback, the assets included within the youngest release in this"
      echo "branch will be deployed. However, they will most probably not work,"
      echo "if you are not deploying this release"
    fi
  fi

  if ! exist "$DEPLOY_TO/shared"; then
    setup

    echo "the initial setup has been done and a sample config has been copied"
    echo "to the host. Please modify your environment or .env on the host so"
    echo "that it reflects your deployment. Then run this script again"

    exit 0
  fi

  deploy_code
  cleanup

  within_do $CURRENT_PATH "bundle config set --local clean 'true'"
  within_do $CURRENT_PATH "bundle config set --local path '$SHARED_PATH/bundle.$RUBY_VERSION'"
  within_do $CURRENT_PATH "bundle config set --local without 'development:test'"
  within_do $CURRENT_PATH "bundle --quiet"

  remote "ln -sfn $SHARED_PATH/log $CURRENT_PATH/log"
  remote "ln -sfn $SHARED_PATH/tmp $CURRENT_PATH/tmp"
  remote "ln -sfn $SHARED_PATH/env $CURRENT_PATH/.env"

  if dbexists; then
    within_do $CURRENT_PATH "RAILS_ENV=production bundle exec rake db:migrate"
  else
    within_do $DEPLOY_TO/current "RAILS_ENV=production bundle exec rake db:setup"
  fi

  within_do $CURRENT_PATH "RAILS_ENV=production bundle exec rake tmp:clear"

  if [ "$BUILD_FRONTEND" = "true" ]; then
    if which npm > /dev/null ; then
      local "npm install"
      local "npm run build"
      upload "public/*.js" "$CURRENT_PATH/public/"
      upload "public/*.css" "$CURRENT_PATH/public/"
      upload "public/fonts/" "$CURRENT_PATH/public/fonts/"
      upload "public/images/" "$CURRENT_PATH/public/images/"
      upload "public/index.html" "$CURRENT_PATH/public/index.html"
    fi
  fi

  remote "touch $CURRENT_PATH/tmp/restart.txt"

  finalize
}


# Variables

TIMESTAMP=`date +"%Y%m%d%H%M%S"`
CURRENT_PATH="$DEPLOY_TO/releases/$TIMESTAMP"
SHARED_PATH="$DEPLOY_TO/shared"
OLD_CURRENT_PATH="$DEPLOY_TO/current"
REVISION=`git rev-parse $COMMIT`

RED="\e[0;31m"
GREEN="\e[0;32m"
BLUE="\e[0;34m"
LIGHTBLUE="\e[1;34m"
NOCOLOR="\e[0m"


# Generic functions

function within_do {
  remote "cd $1 ; $2"
}

function remote {
  echo -e "${BLUE}$HOST${NOCOLOR}: ${LIGHTBLUE}$1${NOCOLOR}" 1>&2
  ssh -i $SSH_KEY $HOST -p $PORT "bash -c \"$1\""
  STATUS=$?

  if [[ $STATUS != 0 ]] ; then
    echo -e "${RED}deployment failed with status code $STATUS${NOCOLOR}"
    exit $STATUS
  fi
}

function local {
  echo -e "${BLUE}locally${NOCOLOR}: ${LIGHTBLUE}$1${NOCOLOR}" 1>&2
  bash -c "$1"
  STATUS=$?

  if [[ $STATUS != 0 ]] ; then
    echo -e "${RED}deployment failed with status code $STATUS${NOCOLOR}"
    exit $STATUS
  fi
}

function setup {
  remote "mkdir -p $DEPLOY_TO/releases"
  remote "mkdir -p $DEPLOY_TO/shared/tmp/pids"
  remote "mkdir -p $DEPLOY_TO/shared/data"
  remote "mkdir -p $DEPLOY_TO/shared/log"

  upload ".env.example" "$SHARED_PATH/env"
}

function exist {
  ssh $HOST -i $SSH_KEY -p $PORT "bash -c \"test -e $1\""
  STATUS=$?
  echo $STATUS
  return $STATUS
}

function dbexists {
  CMD="cd $DEPLOY_TO/current && RAILS_ENV=production bundle exec rake db:version"
  ssh -i $SSH_KEY $HOST -p $PORT "bash -c \"$CMD\" 2> /dev/null"
  STATUS=$?
  return $STATUS
}

function deploy_code {
  local "git archive --format=tar $COMMIT | gzip > deploy.tar.gz"
  local "scp -i $SSH_KEY -P $PORT deploy.tar.gz $HOST:$DEPLOY_TO/deploy.tar.gz"
  local "rm deploy.tar.gz"

  remote "mkdir $CURRENT_PATH"
  within_do $CURRENT_PATH "tar xzf ../../deploy.tar.gz"
  remote "echo $REVISION > $CURRENT_PATH/REVISION"
  remote "echo $RUBY_VERSION > $CURRENT_PATH/.ruby-version"
  remote "rm $DEPLOY_TO/deploy.tar.gz"
  remote "ln -sfn $CURRENT_PATH $DEPLOY_TO/current"
}

function cleanup {
  EXPIRED=`remote "(ls -t $DEPLOY_TO/releases | head -n $KEEP ; ls $DEPLOY_TO/releases) | sort | uniq -u | xargs"`
  for d in $EXPIRED ; do
    remote "rm -rf $DEPLOY_TO/releases/$d"
  done
}

function finalize {
  echo -e "${GREEN}deployment successful${NOCOLOR}"
}

function upload {
  FROM=$1
  TO=$2
  OPTS="-rvqtzh --rsh=ssh -e 'ssh -i $SSH_KEY -p $PORT'"

  local "rsync $OPTS $FROM $HOST:$TO"
}


# Main

deploy

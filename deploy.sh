#!/bin/bash -e

# Copyright (c) 2014 Moritz Schepp <moritz.schepp@gmail.com>
# Distributed under the GNU GPL v3. For full terms see
# http://www.gnu.org/licenses/gpl-3.0.txt

# This is a deploy script for generic apps. Modify the deploy function to suit
# your needs.

# Load user settings

. ./deploy.config.sh && $1

# Deploy

function deploy {
  if ! which npm > /dev/null ; then
    echo "WARNING, npm was not found so some assets can't be compiled. As a"
    echo "fallback, the assets included within the youngest release in this"
    echo "branch will be deployed. However, they will most probably not work,"
    echo "if you are not deploying this release"
  fi

  if ! exist "$DEPLOY_TO/shared"; then
    setup

    echo "the initial setup has been done and a sample config has been copied"
    echo "to the host. Please modify config/database.yml on the host so that it"
    echo "reflects your database connection. Then run this script again"

    exit 0
  fi

  if git cat-file -e $REVISION:bin/delayed_job ; then
    within_do $OLD_CURRENT_PATH "RAILS_ENV=production bundle exec bin/delayed_job stop 2> /dev/null || true"
  else
    within_do $OLD_CURRENT_PATH "RAILS_ENV=production bundle exec script/delayed_job stop 2> /dev/null || true"
  fi

  deploy_code
  cleanup

  within_do $CURRENT_PATH "bundle --clean --quiet --deployment --without test development --path $SHARED_PATH/bundle"

  remote "ln -sfn $SHARED_PATH/database.yml $CURRENT_PATH/config/database.yml"
  remote "ln -sfn $SHARED_PATH/contact.txt $CURRENT_PATH/config/contact.txt"
  remote "ln -sfn $SHARED_PATH/help.yml $CURRENT_PATH/config/help.yml"
  remote "ln -sfn $SHARED_PATH/legal.txt $CURRENT_PATH/config/legal.txt"
  remote "ln -sfn $SHARED_PATH/log $CURRENT_PATH/log"
  remote "ln -sfn $SHARED_PATH/tmp $CURRENT_PATH/tmp"
  remote "ln -sfn $SHARED_PATH/data $CURRENT_PATH/data"
  remote "ln -sfn $SHARED_PATH/kor.yml $CURRENT_PATH/config/kor.yml"
  remote "ln -sfn $SHARED_PATH/kor.app.yml $CURRENT_PATH/config/kor.app.yml"

  if dbexists; then
    within_do $CURRENT_PATH "RAILS_ENV=production bundle exec rake db:migrate"
  else
    within_do $DEPLOY_TO/current "RAILS_ENV=production bundle exec rake db:setup"
  fi

  within_do $CURRENT_PATH "RAILS_ENV=production bundle exec rake tmp:clear"
  within_do $CURRENT_PATH "RAILS_ENV=production bundle exec rake assets:precompile"
  if git cat-file -e $REVISION:bin/delayed_job ; then
    within_do $OLD_CURRENT_PATH "RAILS_ENV=production bundle exec bin/delayed_job start"
  else
    within_do $OLD_CURRENT_PATH "RAILS_ENV=production bundle exec script/delayed_job start"
  fi

  remote "mkdir -p $CURRENT_PATH/public/media/images"
  remote "ln -sfn $SHARED_PATH/data/media/preview $CURRENT_PATH/public/media/images/preview"
  remote "ln -sfn $SHARED_PATH/data/media/thumbnail $CURRENT_PATH/public/media/images/thumbnail"
  remote "ln -sfn $SHARED_PATH/data/media/icon $CURRENT_PATH/public/media/images/icon"

  within_do $CURRENT_PATH "RAILS_ENV=production bundle exec bin/kor secrets"

  if which npm > /dev/null ; then
    local "npm install"
    local "npm run build"
    upload "public/widget-test.html" "$CURRENT_PATH/public/widget-test.html"
    upload "public/*.js" "$CURRENT_PATH/public/"
    upload "public/*.css" "$CURRENT_PATH/public/"
    upload "public/fonts/" "$CURRENT_PATH/public/fonts/"
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

  git show $COMMIT:config/database.yml.example > tmp/database.yml.example
  upload tmp/database.yml.example "$SHARED_PATH/database.yml"
  rm tmp/database.yml.example
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

#!/bin/bash -e

export RAILS_ENV=production
export RAILS_SERVE_STATIC_FILES=true

if ! [ -f /opt/kor/data/db_created.state ]; then
  bundle exec rake db:setup
  bundle exec bin/kor index-all
  touch /opt/kor/data/db_created.state
fi

bundle exec rake db:migrate

bundle exec puma -b tcp://0.0.0.0 -p 3000 -e production -v

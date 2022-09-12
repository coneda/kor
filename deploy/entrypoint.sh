#!/bin/bash -e

export RAILS_ENV=production
export RAILS_SERVE_STATIC_FILES=true

until mysql -u root -proot -h db -e 'select 1' 2> /dev/null; do
  echo "waiting for mysql to be ready"
  sleep 1
done

if ! [ -f /opt/kor/data/db_created.state ]; then
  bundle exec rake db:setup
  bundle exec bin/kor index-all
  touch /opt/kor/data/db_created.state
fi

bundle exec rake db:migrate

bundle exec puma \
  -b tcp://0.0.0.0 \
  -p 3000 \
  -e production \
  --pidfile tmp/puma.pid
  -v

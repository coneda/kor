#!/bin/bash

su -c "cd /opt/kor/current ; RAILS_ENV=production bundle exec rake db:setup" kor
su -c "cd /opt/kor/current && bundle exec rake assets:precompile" kor
su -c "cd /opt/kor/current && bundle exec rake kor:deploy:media_preview" kor
su -c "touch /opt/kor/current/tmp/restart.txt" kor

/etc/init.d/sunspot start
/etc/init.d/delayed_job start
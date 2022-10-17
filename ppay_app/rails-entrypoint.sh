#!/bin/sh

set -e

#cd $APP_HOME

rm -f tmp/pids/server.pid

bundle exec rake db:migrate 2>/dev/null || bundle exec rake db:setup

#bundle exec whenever --update-crontab

#crontab -l

bundle exec rails server Puma -b 0.0.0.0

exec "$@"

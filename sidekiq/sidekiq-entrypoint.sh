#!/bin/sh

set -e

#cd $APP_HOME

rm -f tmp/pids/server.pid

bundle exec whenever --update-crontab

crontab -l

bundle exec sidekiq

exec "$@"

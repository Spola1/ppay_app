#!/usr/bin/env bash

set -e

if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

#
bundle exec whenever --update-crontab
crontab -l
#


bundle exec sidekiq



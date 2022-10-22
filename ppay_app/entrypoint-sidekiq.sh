#!/usr/bin/env bash

set -e

#
bundle exec whenever --update-crontab
crontab -l
cron -f
#

bundle exec sidekiq

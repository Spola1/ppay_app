#!/usr/bin/env bash

set -e

bundle exec whenever --update-crontab
crontab -l

cron && tail -f /var/log/cron.log

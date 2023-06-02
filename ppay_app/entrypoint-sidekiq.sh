#!/usr/bin/env bash

set -e

if [ "$RAILS_ENV" == "development" ]; then
  bundle exec rake assets:clean --silent
else
  bundle exec rake assets:precompile --silent
fi

bundle exec sidekiq

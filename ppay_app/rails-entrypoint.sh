#!/bin/sh
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f tmp/pids/server.pid

bundle exec rake db:migrate 2>/dev/null || bundle exec rake db:setup

#bundle exec whenever --update-crontab
#crontab -l

bundle exec rails server Puma -b 0.0.0.0

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"


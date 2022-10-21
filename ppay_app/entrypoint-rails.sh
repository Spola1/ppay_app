#!/usr/bin/env bash

set -e

# ------ #
# Remove a potentially pre-existing server.pid for Rails.
rm -f tmp/pids/server.pid

bundle exec rake db:migrate 2>/dev/null || bundle exec rake db:setup
# ------ #

# Always keep this here as it ensures your latest built assets make their way
# into your volume persisted public directory.
cp -r /public /app

# Sprockets will use the first sprockets file it finds not the latest one. We
# need to delete all of the old sprockets files except for the one that was
# last built into the image. That's what the code below does.

# shellcheck disable=SC2125
manifest_files=/app/public/assets/.sprockets-manifest-*.json

if compgen -G "${manifest_files}" > /dev/null 2>&1; then
  # shellcheck disable=SC2086,SC2061
  find \
    ${manifest_files} \
    -type f ! -name "$(basename /public/assets/.sprockets-manifest-*.json)" \
    -delete
fi

bundle exec rails server Puma -b 0.0.0.0 -p 3000

exec "$@"

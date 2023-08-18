# frozen_string_literal: true

# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

ENV.each_key do |key|
  env key.to_sym, ENV.fetch(key, nil)
end

set :environment, ENV.fetch('RAILS_ENV', nil)
set :output, '/var/log/cron.log'

every 1.minute do
  runner 'RateSnapshots::GetAllRatesJob.perform_async'
  runner 'Payments::CancelExpiredJob.perform_async'
end

every 5.minutes do
  runner 'PgHero.capture_query_stats'
end

# не забываем:
# Now, you need to update the scheduled jobs to system
#
# whenever --update-crontab

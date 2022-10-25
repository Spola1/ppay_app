sidekiq_config = { url: ENV['REDIS_HOST'].present? ? "redis://#{ ENV['REDIS_HOST'] }:6379/0" : 'redis://redis:6379/0' }

Sidekiq.configure_server do |config|
  config.redis = sidekiq_config
end

Sidekiq.configure_client do |config|
  config.redis = sidekiq_config
end

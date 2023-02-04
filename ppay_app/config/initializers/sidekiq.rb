sidekiq_config = { url: ENV['REDIS_HOST'].present? ? "redis://#{ ENV['REDIS_HOST'] }:6379" : 'redis://localhost:6379' }

Sidekiq.configure_server do |config|
  config.redis = sidekiq_config
end

Sidekiq.configure_client do |config|
  config.redis = sidekiq_config
end

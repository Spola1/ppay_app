HealthCheck.setup do |config|
  config.standard_checks = %w[site database migrations cache redis sidekiq-redis]
  config.redis_url = ENV['REDIS_HOST'].present? ? "redis://#{ENV['REDIS_HOST']}:6379" : 'redis://localhost:6379'
  config.redis_password = nil
end

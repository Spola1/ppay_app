# frozen_string_literal: true

require 'capybara/rails'

Capybara.configure do |config|
  config.app_host = "http://#{Rails.configuration.action_controller.default_url_options[:host]}"
  config.default_max_wait_time = 15
end

# frozen_string_literal: true

Capybara.configure do |config|
  config.app_host = "http://#{Rails.configuration.action_controller.default_url_options[:host]}"
end

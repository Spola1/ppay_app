# frozen_string_literal: true

original_url_options = Rails.application.routes.default_url_options

RSpec.shared_context 'default_url_options' do
  before do
    next unless Capybara.current_session.server

    Rails.application.routes.default_url_options = { host: Capybara.current_session.server.host,
                                                     port: Capybara.current_session.server.port }
    Rails.application.config.action_mailer.default_url_options = Rails.application.routes.default_url_options
    Rails.application.config.action_controller.default_url_options = Rails.application.routes.default_url_options
    Rails.application.config.active_storage.url_options = Rails.application.routes.default_url_options
    Capybara.app_host = "http://#{Rails.application.routes.default_url_options[:host]}:#{Rails.application.routes.default_url_options[:port]}"
  end

  after do
    Rails.application.routes.default_url_options = original_url_options
    Rails.application.config.action_mailer.default_url_options = Rails.application.routes.default_url_options
    Rails.application.config.action_controller.default_url_options = Rails.application.routes.default_url_options
    Rails.application.config.active_storage.url_options = Rails.application.routes.default_url_options
    Capybara.app_host = "http://#{Rails.application.routes.default_url_options[:host]}:#{Rails.application.routes.default_url_options[:port]}"
  end
end

RSpec.configure do |config|
  config.include_context 'default_url_options', type: :feature, js: true
end

# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'
require_relative '../lib/rack/raw_json'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PpayApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    config.time_zone = 'Moscow'
    # config.eager_load_paths << Rails.root.join("extras")
    config.generators.test_framework = :rspec

    config.autoload_paths << Rails.root.join('lib')

    config.i18n.available_locales = [:id, :kk, :ky, :ru, :tg, :tr, :uk, :uz, :azn]
  
    config.i18n.default_locale = :ru

    config.active_storage.content_types_to_serve_as_binary -= ['image/svg+xml']
    config.active_storage.content_types_allowed_inline += ['image/svg+xml']
    config.active_storage.service_urls_expire_in = 1.week

    unless Rails.env.production?
      RSpec.configure do |config|
        config.swagger_dry_run = false
      end
    end

    config.middleware.use Rack::RawJSON
  end
end

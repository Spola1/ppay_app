# frozen_string_literal: true

# FilePond wants csrf-token, so allow forgery protection for Capybara sessions

RSpec.shared_context 'allow_forgery_protection' do
  allow_forgery_protection = ActionController::Base.allow_forgery_protection

  before do
    next unless Capybara.current_session.server

    ActionController::Base.allow_forgery_protection = true
  end

  after do
    ActionController::Base.allow_forgery_protection = allow_forgery_protection
  end
end

RSpec.configure do |config|
  config.include_context 'allow_forgery_protection', type: :feature, js: true
end

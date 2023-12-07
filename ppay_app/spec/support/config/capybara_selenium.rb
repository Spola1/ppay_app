# frozen_string_literal: true

require 'selenium-webdriver'

Capybara.server = :puma, { Silent: true }

Capybara.register_driver :chrome_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new

  options.add_argument('--headless')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--disable-browser-side-navigation')
  options.add_argument('--window-size=1920,1080')

  Capybara::Selenium::Driver.new(app, browser: :chrome, options:)
end

Capybara.register_driver :chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new

  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--disable-browser-side-navigation')
  options.add_argument('--start-maximized')

  Capybara::Selenium::Driver.new(app, browser: :chrome, options:)
end

Capybara.javascript_driver = :chrome_headless
Capybara.default_driver = :rack_test

# frozen_string_literal: true

include ActionDispatch::TestProcess::FixtureFile

FactoryBot.define do
  factory :form_customization do
    button_color { 'red' }
    background_color { 'pink' }
    logo { Rack::Test::UploadedFile.new('spec/fixtures/test_files/sample.jpeg', 'image/png') }
  end
end

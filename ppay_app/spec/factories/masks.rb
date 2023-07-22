# frozen_string_literal: true

FactoryBot.define do
  factory :mask do
    app { 'MyString' }
    request_type { 'MyString' }
    mask { 'MyString' }
  end
end

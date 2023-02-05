# frozen_string_literal: true

FactoryBot.define do
  factory :crypto_wallet do
    address { 'MyString' }
    user { nil }
  end
end

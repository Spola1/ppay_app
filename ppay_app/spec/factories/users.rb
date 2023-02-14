# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { FFaker::Internet.email }
    password { FFaker::Internet.password(10) }
    name { 'Alexey' }

    trait :merchant do
      type { 'Merchant' }
    end
  end
end

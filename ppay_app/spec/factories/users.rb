# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { FFaker::Internet.email }
    password { FFaker::Internet.password(10) }

    trait :ppay do
      type { 'Ppay' }
    end
  end
end

# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { FFaker::Internet.email }
    password { FFaker::Internet.password(10) }

    transient do
      initial_balance { 1000 }
    end

    after(:create) do |user, context|
      user.balance.deposit(context.initial_balance, context.initial_balance)
    end

    trait :ppay do
      type { 'Ppay' }
    end

    trait :admin do
      type { 'Admin' }
    end
  end
end

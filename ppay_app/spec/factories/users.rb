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

    trait :super_admin do
      type { 'SuperAdmin' }
    end

    trait :agent do
      type { 'Agent' }
    end

    factory :ppay,        traits: %i[ppay]
    factory :admin,       traits: %i[admin]
    factory :super_admin, traits: %i[super_admin]
    factory :agent,       traits: %i[agent]
  end
end

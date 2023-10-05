# frozen_string_literal: true

FactoryBot.define do
  factory :working_group do
    email { FFaker::Internet.email }
    password { FFaker::Internet.password(10) }
    name { 'working_group' }

    transient do
      initial_balance { 1000 }
    end

    after(:create) do |user, context|
      user.balance.deposit(context.initial_balance, context.initial_balance)
    end
  end
end

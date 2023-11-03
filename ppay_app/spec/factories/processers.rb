# frozen_string_literal: true

FactoryBot.define do
  factory :processer do
    type { 'Processer' }
    email { FFaker::Internet.email }
    password { FFaker::Internet.password(10) }

    transient do
      initial_balance { 1000 }
    end

    after(:create) do |processer, context|
      processer.balance.deposit(context.initial_balance, context.initial_balance)
    end
  end
end

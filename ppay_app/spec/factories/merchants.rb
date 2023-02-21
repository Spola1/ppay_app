# frozen_string_literal: true

FactoryBot.define do
  factory :merchant do
    type { 'Merchant' }
    email { FFaker::Internet.email }
    password { FFaker::Internet.password(10) }

    after(:create) do |merchant|
      merchant.balance.deposit(1000)
    end

    trait :with_all_kind_of_payments do
      after(:create) do |user, _evaluator|
        create :payment, :withdrawal, :transferring, merchant: user
        create :payment, :deposit, :confirming, merchant: user
        create :payment, :deposit, merchant: user
      end
    end
  end
end

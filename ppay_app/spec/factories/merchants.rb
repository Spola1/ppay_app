# frozen_string_literal: true

FactoryBot.define do
  factory :merchant do
    type { 'Merchant' }
    email { FFaker::Internet.email }
    password { FFaker::Internet.password(10) }
    nickname { 'AvangardBet' }
    name { 'Петр Петрович' }
    check_required { true }
    account_number_required { false }
    crypto_wallet
    usdt_trc20_address { 'ZtK2GioEtevoAJq3NwQDbLyJDfjW7AAAUt' }

    transient do
      initial_balance { 1000 }
    end

    after(:create) do |merchant, context|
      merchant.balance.deposit(context.initial_balance, context.initial_balance)
    end

    trait :with_all_kind_of_payments do
      after(:create) do |user, _evaluator|
        create :payment, :withdrawal, :transferring, merchant: user
        create :payment, :deposit, :confirming, merchant: user
        create :payment, :deposit, merchant: user
      end
    end

    trait :with_mixed_balance_freeze_type do
      balance_freeze_type { :mixed }
      short_freeze_days { 3 }
      long_freeze_days { 10 }
      long_freeze_percentage { 30 }
    end
  end
end

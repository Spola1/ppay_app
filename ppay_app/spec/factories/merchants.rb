# frozen_string_literal: true

FactoryBot.define do
  factory :merchant do
    type { 'Merchant' }
    email { FFaker::Internet.email }
    password { FFaker::Internet.password(10) }
    nickname { 'AvangardBet' }
    name { 'Петр Петрович' }
    check_required { true }
    account_number_required { true }
    crypto_wallet
    usdt_trc20_address { 'ZtK2GioEtevoAJq3NwQDbLyJDfjW7AAAUt' }

    after(:create) do |merchant|
      merchant.balance.deposit(1000, 10_000)
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

# frozen_string_literal: true

FactoryBot.define do
  factory :advertisement do
    processer

    national_currency { 'RUB' }
    payment_system { 'AlfaBank' }
    card_number { '1111111111111111' }
    status { true }

    trait :deposit do
      direction { 'Deposit' }
    end

    trait :withdrawal do
      direction { 'Withdrawal' }
    end
  end
end

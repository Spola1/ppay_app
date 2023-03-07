# frozen_string_literal: true

FactoryBot.define do
  factory :advertisement do
    processer

    national_currency { 'RUB' }
    payment_system { 'AlfaBank' }
    card_number { '1111111111111111' }
    status { true }
    max_summ { 10_000 }
    min_summ { 10 }

    trait :deposit do
      direction { 'Deposit' }
    end

    trait :withdrawal do
      direction { 'Withdrawal' }
    end

    trait :max_summ do
      max_summ { 10_000 }
    end

    trait :min_summ do
      min_summ { 10 }
    end

    trait :payment_system do
      payment_system { 'AlfaBank' }
    end
  end
end

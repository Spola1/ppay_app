# frozen_string_literal: true

FactoryBot.define do
  factory :advertisement do
    processer

    national_currency { 'RUB' }
    payment_system { 'Sberbank' }
    card_number { '1111111111111111' }
    card_owner_name { 'John Doe' }
    sbp_phone_number { '+1234567890' }
    status { true }
    max_summ { 10_000 }
    min_summ { 10 }

    trait :deposit do
      direction { 'Deposit' }
    end

    trait :withdrawal do
      direction { 'Withdrawal' }
    end
  end
end

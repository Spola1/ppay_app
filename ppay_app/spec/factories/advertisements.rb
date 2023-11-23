# frozen_string_literal: true

FactoryBot.define do
  factory :advertisement do
    processer

    national_currency { 'RUB' }
    payment_system { 'Sberbank' }
    card_owner_name { 'John Doe' }
    sbp_phone_number { '+1234567890' }
    status { true }
    max_summ { 100_000 }
    min_summ { 10 }
    simbank_auto_confirmation { true }
    save_incoming_requests_history { true }
    phone { '79231636742' }
    simbank_card_number { '8412' }
    simbank_sender { 'Raiffeisen' }
    direction { 'Deposit' }
    daily_usdt_limit { 200 }

    trait :withdrawal do
      direction { 'Withdrawal' }
    end

    card_number { direction == 'Deposit' ? FFaker::Bank.unique.card_number : nil }
  end
end

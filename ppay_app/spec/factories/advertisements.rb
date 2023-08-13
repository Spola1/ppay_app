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
    simbank_auto_confirmation { true }
    phone { '79231636742' }
    simbank_card_number { '8412' }
    simbank_sender { 'Raiffeisen' }
    direction { 'Deposit' }

    trait :withdrawal do
      direction { 'Withdrawal' }
    end
  end
end

# frozen_string_literal: true

FactoryBot.define do
  factory :advertisement do
    processer

    national_currency { 'RUB' }
    payment_system { 'Sberbank' }
    card_number { '1111111111111111' }
    status { true }
    max_summ { 10_000 }
    min_summ { 10 }
    simbank_auto_confirmation { true }
    phone { '79231636742' }
    simbank_card_number { '8412' }
    simbank_sender { 'Raiffeisen' }

    trait :deposit do
      direction { 'Deposit' }
    end

    trait :withdrawal do
      direction { 'Withdrawal' }
    end
  end
end

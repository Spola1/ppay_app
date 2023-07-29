# frozen_string_literal: true

FactoryBot.define do
  factory :rate_snapshot do
    direction { :buy }
    cryptocurrency { 'USDT' }
    value { 61.29 }
    exchange_portal

    payment_system { PaymentSystem.first }

    trait :sell do
      direction { :sell }
    end
  end
end

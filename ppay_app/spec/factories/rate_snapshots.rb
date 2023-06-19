# frozen_string_literal: true

FactoryBot.define do
  factory :rate_snapshot do
    direction { :buy }
    national_currency { 'RUB' }
    cryptocurrency { 'USDT' }
    value { 61.29 }
    exchange_portal

    trait :sell do
      direction { :sell }
    end
  end
end

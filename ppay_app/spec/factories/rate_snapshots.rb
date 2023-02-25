# frozen_string_literal: true

FactoryBot.define do
  factory :rate_snapshot do
    direction { :sell }
    national_currency { 'RUB' }
    cryptocurrency { 'USDT' }
    value { 61.29 }
    exchange_portal
  end
end

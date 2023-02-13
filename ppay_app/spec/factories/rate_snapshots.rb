# frozen_string_literal: true

FactoryBot.define do
  factory :rate_snapshot do
    direction { :buy }
    cryptocurrency { 'USDT' }
    value { 61.29 }
    exchange_portal { association(:exchange_portal) }
  end
end

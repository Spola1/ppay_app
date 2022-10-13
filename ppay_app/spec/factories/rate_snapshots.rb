FactoryBot.define do
  factory :rate_snapshot do
    direction { :buy }
    cryptocurrency { 'USDT' }
    value { 0.6129e2 }
    exchange_portal { association(:exchange_portal) }
  end
end

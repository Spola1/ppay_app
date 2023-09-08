# frozen_string_literal: true

FactoryBot.define do
  factory :payment_system do
    name { 'Sberbank' }
    national_currency { create(:national_currency, name: 'RUB') }
    exchange_portal { ExchangePortal.first || create(:exchange_portal) }
  end
end

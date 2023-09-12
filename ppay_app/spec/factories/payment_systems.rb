# frozen_string_literal: true

FactoryBot.define do
  factory :payment_system do
    name { 'Sberbank' }
    national_currency { NationalCurrency.first }
    exchange_portal { ExchangePortal.first }
  end
end

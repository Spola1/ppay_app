# frozen_string_literal: true

FactoryBot.define do
  factory :payment_system do
    name { 'AlfaBank' }
    national_currency { create(:national_currency, name: 'RUB') }
  end
end

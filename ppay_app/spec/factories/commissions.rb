# frozen_string_literal: true

FactoryBot.define do
  factory :commission do
    merchant
    payment_system

    national_currency { 'RUB' }
    direction { 'Deposit' }
    commission_type { :processer }
    commission { '9.99' }
  end
end

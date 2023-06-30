# frozen_string_literal: true

FactoryBot.define do
  factory :merchant_method do
    merchant { nil }
    payment_system { nil }
    direction { 'Deposit' }
  end
end

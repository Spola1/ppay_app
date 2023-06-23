# frozen_string_literal: true

FactoryBot.define do
  factory :merchant_method do
    merchant { nil }
    payment_way { nil }
    direction { 'Deposit' }
  end
end

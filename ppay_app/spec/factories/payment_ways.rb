# frozen_string_literal: true

FactoryBot.define do
  factory :payment_way do
    payment_system { nil }
    national_currency { nil }
  end
end

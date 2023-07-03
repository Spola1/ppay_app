# frozen_string_literal: true

FactoryBot.define do
  factory :national_currency do
    name { 'UZS' }
    initialize_with { NationalCurrency.find_or_create_by(name:) }
  end
end

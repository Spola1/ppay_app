# frozen_string_literal: true

FactoryBot.define do
  factory :transaction do
    status { 'frozen' }
    transaction_type { 'main' }
  end
end

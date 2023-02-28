# frozen_string_literal: true

FactoryBot.define do
  factory :transaction do
    association :transactionable, factory: :payment, strategy: :create
  end
end

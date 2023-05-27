# frozen_string_literal: true

FactoryBot.define do
  factory :balance_request do
    user { create(:merchant) }
    amount { 1 }
    status { :processing }
  end

  trait :withdraw do
    request_type { 'withdraw' }
  end

  trait :deposit do
    request_type { 'deposit' }
  end
end

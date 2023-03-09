# frozen_string_literal: true

FactoryBot.define do
  factory :balance do
    amount { 1000 }

    trait :with_money do
      amount { 1000 }
    end

    trait :amount do
      amount { 1000 }
    end
  end
end

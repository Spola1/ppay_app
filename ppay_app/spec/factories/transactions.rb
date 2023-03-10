# frozen_string_literal: true

FactoryBot.define do
  factory :transaction do
    association :transactionable, factory: :payment, strategy: :create

    trait :frozen do
      status { 'frozen' }
    end
    
    trait :completed do
      status { 'completed' }
    end
  end
end

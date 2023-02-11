# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    # возвращаем класс STI
    initialize_with do
      klass = type.constantize
      klass.new(attributes)
    end

    email { FFaker::Internet.email }
    password { FFaker::Internet.password(10) }

    trait :merchant do
      type { 'Merchant' }
    end

    trait :with_all_kind_of_payments do
      after(:create) do |user, _evaluator|
        create :payment, :withdrawal, :transferring, merchant: user
        create :payment, :deposit, :confirming, merchant: user
        create :payment, :deposit, merchant: user
      end
    end
  end
end

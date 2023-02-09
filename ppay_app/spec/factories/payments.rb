FactoryBot.define do
  factory :payment, class: Payment do
    initialize_with do
      klass = type.constantize
      klass.new(attributes)
    end

    association :merchant, class: Merchant, factory: :user

    national_currency { 'RUB' }
    national_currency_amount { 100 }

    trait :confirming do
      payment_status { 'confirming' }
    end

    trait :transferring do
      payment_status { 'transferring' }
    end

    trait :withdrawal do
      type { 'Withdrawal' }
    end

    trait :deposit do
      type { 'Deposit' }
    end
  end
end
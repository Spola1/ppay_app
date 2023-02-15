# frozen_string_literal: true

FactoryBot.define do
  factory :payment, class: Payment do
    initialize_with do
      klass = type.constantize
      klass.new(attributes)
    end

    merchant

    uuid { SecureRandom.uuid }
    external_order_id { '1234' }
    national_currency { 'RUB' }
    national_currency_amount { 100 }
    cryptocurrency { 'USDT' }
    payment_system { Settings.payment_systems.first }
    callback_url { FFaker::Internet.http_url }
    redirect_url { FFaker::Internet.http_url }

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

    trait :with_image do
      image { fixture_file_upload('spec/fixtures/test_files/sample.jpeg', 'image/png') }
    end
  end
end

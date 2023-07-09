# frozen_string_literal: true

require 'securerandom'

FactoryBot.define do
  factory :payment, class: Payment do
    initialize_with { type.present? ? type.constantize.new : Payment.new }

    merchant

    external_order_id { '1234' }
    national_currency { 'RUB' }
    national_currency_amount { 100 }
    initial_amount { 100.0 }
    cryptocurrency_amount { 1 }
    cryptocurrency { 'USDT' }
    payment_system { 'Sberbank' }
    callback_url { FFaker::Internet.http_url }
    redirect_url { FFaker::Internet.http_url }
    uuid { SecureRandom.uuid }
    type { nil }
    status_changed_at { Time.now }

    trait :created do
      payment_status { 'created' }
    end

    trait :confirming do
      payment_status { 'confirming' }
    end

    trait :transferring do
      payment_status { 'transferring' }
    end

    trait :processer_search do
      payment_status { 'processer_search' }
    end

    trait :completed do
      payment_status { 'completed' }
    end

    trait :cancelled do
      payment_status { 'cancelled' }
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

    trait :by_client do
      cancellation_reason { 0 }
    end

    trait :IDR do
      national_currency { 'IDR' }
    end

    trait :Tinkoff do
      payment_system { 'Tinkoff' }
    end

    trait :with_transactions do
      transactions do
        [build(:transaction, transaction_type: :main),
         build(:transaction, transaction_type: :processer_commission),
         build(:transaction, transaction_type: :ppay_commission)]
      end
    end

    trait :with_completed_transactions do
      transactions do
        [build(:transaction, transaction_type: :main, status: :completed),
         build(:transaction, transaction_type: :processer_commission, status: :completed),
         build(:transaction, transaction_type: :ppay_commission, status: :completed)]
      end
    end

    trait :with_cancelled_transactions do
      transactions do
        [build(:transaction, transaction_type: :main, status: :cancelled),
         build(:transaction, transaction_type: :processer_commission, status: :cancelled),
         build(:transaction, transaction_type: :ppay_commission, status: :cancelled)]
      end
    end
  end
end

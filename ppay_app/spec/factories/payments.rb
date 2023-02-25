# frozen_string_literal: true

FactoryBot.define do
  factory :payment, class: Payment do
    merchant

    uuid { SecureRandom.uuid }
    external_order_id { '1234' }
    national_currency { 'RUB' }
    national_currency_amount { 100 }
    cryptocurrency_amount { 1 }
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

    trait :processer_search do
      payment_status { 'processer_search' }
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

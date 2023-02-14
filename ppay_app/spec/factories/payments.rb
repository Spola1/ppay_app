FactoryBot.define do
  factory :payment, class: Payment do
    initialize_with do
      klass = type.constantize
      klass.new(attributes)
    end

    merchant

    national_currency { 'RUB' }
    national_currency_amount { 100 }
    cryptocurrency_amount { 1 }
    payment_system { 'AlfaBank' }
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
  end
end

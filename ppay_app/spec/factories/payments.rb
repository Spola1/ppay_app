FactoryBot.define do
  factory :payment do
    association :merchant
    national_currency { 'RUB' }
    national_currency_amount { 50 }
    redirect_url { 'file/' }
    callback_url { 'file/payment/' }
    arbitration { true }
    payment_status { :processer_search }
    external_order_id { '123' }

    trait :cancelled do
      payment_status { :cancelled }
    end
  end
end
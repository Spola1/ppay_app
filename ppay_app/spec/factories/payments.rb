require 'securerandom'

FactoryBot.define do
  factory :payment do
    association :merchant
    national_currency { 'RUB' }
    national_currency_amount { 100 }
    redirect_url { 'file/' }
    callback_url { 'file/payment/' }
    arbitration { true }
    payment_status { :processer_search }
    external_order_id { '123' }
    uuid { SecureRandom.uuid }


    trait :cancelled do
      payment_status { :cancelled }
    end

    trait :created_at do
      created_at { 'Fri, 17 Feb 2023 22:53:22.595096000 MSK +03:00' }
    end

  end
end
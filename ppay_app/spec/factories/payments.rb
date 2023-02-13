FactoryBot.define do
  factory :payment do
    national_currency { 'RUB' }
    national_currency_amount { 50 }
    redirect_url { 'file/' }
    callback_url { 'file/payment/' }
    arbitration { true }
    payment_status { :processer_search }

    trait :cancelled do
      payment_status { :cancelled }
    end
  end
end
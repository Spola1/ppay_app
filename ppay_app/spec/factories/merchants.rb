# Merchant.create(email: 'merchant@test.com', password: 'NQg6By9QncR5KssZ', nickname: 'AvangardBet',
#                 name: 'Петр Петрович'

FactoryBot.define do
  factory :merchant do
    email { FFaker::Internet.email }
    password { FFaker::Internet.password(10) }
    nickname { 'AvangardBet' }
    name { 'Петр Петрович' }

    after(:create) do |merchant|
      create(:api_key, bearer: merchant)
    end
  end
end
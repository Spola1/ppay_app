FactoryBot.define do
  factory :user do
    email { FFaker::Internet.email }
    password { FFaker::Internet.password(10) }

    trait :merchant do
      type { 'Merchant' }
    end
  end
end

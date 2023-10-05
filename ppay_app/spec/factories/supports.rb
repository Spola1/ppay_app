# frozen_string_literal: true

FactoryBot.define do
  factory :support do
    type { 'Support' }
    email { FFaker::Internet.email }
    password { FFaker::Internet.password(10) }
    nickname { 'Support' }
    name { 'Саппорт Саппортович' }
  end
end

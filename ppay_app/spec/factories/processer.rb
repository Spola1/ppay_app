# frozen_string_literal: true

FactoryBot.define do
  factory :processer do
    type { 'Processer' }
    email { FFaker::Internet.email }
    password { FFaker::Internet.password(10) }
  end
end
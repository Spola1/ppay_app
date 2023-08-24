# frozen_string_literal: true

FactoryBot.define do
  factory :working_group do
    email { FFaker::Internet.email }
    password { FFaker::Internet.password(10) }
    name { 'working_group' }
  end
end

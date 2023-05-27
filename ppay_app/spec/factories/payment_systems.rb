# frozen_string_literal: true

FactoryBot.define do
  factory :payment_system do
    name { FFaker::InternetSE.company_name_single_word }
  end
end

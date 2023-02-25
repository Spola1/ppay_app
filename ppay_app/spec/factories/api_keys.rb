# frozen_string_literal: true

FactoryBot.define do
  factory :api_key do
    bearer_id { 6 }
    bearer_type { 'User' }
  end
end

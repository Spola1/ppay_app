# frozen_string_literal: true

FactoryBot.define do
  factory :setting do
    receive_requests_enabled { false }
  end
end

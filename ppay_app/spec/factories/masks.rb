# frozen_string_literal: true

FactoryBot.define do
  factory :mask do
    sender { 'Raiffeisen' }

    trait :card_number do
      regexp_type { 'Номер счёта' }
      regexp { '/\\*([0-9]+)/' }
    end

    trait :amount do
      regexp_type { 'Сумма' }
      regexp { '/(\d+\.\d+)/' }
      thousands_separator { '.' }
      decimal_separator { ',' }
    end
  end
end

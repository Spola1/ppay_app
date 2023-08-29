# frozen_string_literal: true

class RateSnapshot < ApplicationRecord
  belongs_to :exchange_portal
  belongs_to :payment_system
  # к каждому снэпшоту курса может быть привязано множество платежей
  has_many   :payments

  enum direction: {
    buy: 'buy',
    sell: 'sell'
  }

  scope :by_payment_system,
        lambda { |payment_system|
          where(payment_system: payment_system&.payment_system_copy || payment_system)
        }
  scope :by_national_currency,
        lambda { |national_currency|
          where(payment_system: national_currency.payment_systems)
        }

  scope :by_cryptocurrency, ->(currency) { where(cryptocurrency: currency) }

  def to_crypto(amount, fee_percentage)
    amount / (value + ((value / 100) * fee_percentage))
  end

  def to_national_currency(amount)
    amount * value
  end
end

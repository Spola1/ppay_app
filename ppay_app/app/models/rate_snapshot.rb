# frozen_string_literal: true

class RateSnapshot < ApplicationRecord
  belongs_to :exchange_portal
  belongs_to :payment_system, optional: true
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

  def adjust_rate(fee_percentage)
    value + (value / 100 * fee_percentage)
  end

  def to_national_currency(amount)
    amount * value
  end

  def self.recent_buy_by_national_currency_name(name)
    rates = RateSnapshot.buy.by_national_currency(NationalCurrency.find_by(name:))

    rates.where(created_at: 2.minutes.ago..).order(value: :desc).first(5).last ||
      rates.order(created_at: :asc).last
  end
end

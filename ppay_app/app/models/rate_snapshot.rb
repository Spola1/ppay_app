# frozen_string_literal: true

class RateSnapshot < ApplicationRecord
  belongs_to :exchange_portal
  # к каждому снэпшоту курса может быть привязано множество платежей
  has_many   :payments

  enum direction: {
    buy: 'buy',
    sell: 'sell'
  }

  scope :by_national_currency, ->(currency) { where(national_currency: currency) }
  scope :by_cryptocurrency,    ->(currency) { where(cryptocurrency: currency) }

  def to_crypto(amount)
    amount / value
  end
end

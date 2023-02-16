# frozen_string_literal: true

class Merchant < User
  has_many :payments,    foreign_key: :merchant_id
  has_many :deposits,    foreign_key: :merchant_id
  has_many :withdrawals, foreign_key: :merchant_id
  has_many :cards

  belongs_to :agent, optional: true

  enum unique_amount: {
    none: 0,
    integer: 1,
    decimal: 2
  }, _prefix: true
end

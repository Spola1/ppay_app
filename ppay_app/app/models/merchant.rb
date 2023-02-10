# frozen_string_literal: true

class Merchant < User
  has_many :payments,    foreign_key: :merchant_id
  has_many :deposits,    foreign_key: :merchant_id
  has_many :withdrawals, foreign_key: :merchant_id
  has_many :cards

  belongs_to :agent, optional: true

  enum unique_amount: {
    none: 0, #ArgumentError: You tried to define an enum named "unique_amount" on the model "Merchant", but this will generate a class method "none", which is already defined by Active Record.
    integer: 1,
    decimal: 2
  }
end

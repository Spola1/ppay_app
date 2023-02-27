# frozen_string_literal: true

class Advertisement < ApplicationRecord
  include CardNumberSettable

  has_many :payments
  has_many :deposits
  has_many :withdrawals
  # STI модель - processer < user
  belongs_to :processer

  enum payment_system_type: [:card_number], _prefix: true

  scope :active,               -> { where(status: true) }
  scope :by_payment_system,    ->(payment_system) { where(payment_system:) }
  scope :by_amount,            ->(amount) { where('max_summ >= :amount AND min_summ <= :amount', amount:) }
  scope :by_processer_balance, ->(amount) { joins(processer: :balance).where('balances.amount >= ?', amount) }
  scope :by_direction,         ->(direction) { where(direction:) }

  validates_presence_of :direction, :national_currency, :cryptocurrency, :payment_system
  validates :card_number, length: { is: 16 }, if: -> { direction == 'Deposit' }
end

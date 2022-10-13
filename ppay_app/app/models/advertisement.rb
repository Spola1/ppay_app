# frozen_string_literal: true

class Advertisement < ApplicationRecord
  has_many :payments
  # STI модель - processer < user
  belongs_to :processer

  scope :active,               -> { where(status: true) }
  scope :by_payment_system,    ->(payment_system) { where(payment_system: payment_system) }
  scope :by_amount,            ->(amount) { where('max_summ >= :amount AND min_summ <= :amount', amount: amount) }
  scope :by_processer_balance, ->(amount) { joins(processer: :balance).where('balances.amount >= ?', amount) }
end

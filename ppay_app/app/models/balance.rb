# frozen_string_literal: true

class Balance < ApplicationRecord
  has_many :from_transactions, class_name: 'Transaction', foreign_key: :from_balance_id
  has_many :to_transactions, class_name: 'Transaction', foreign_key: :to_balance_id

  belongs_to :balanceable, polymorphic: true

  validates :amount, numericality: { greater_than_or_equal_to: 0 }

  def withdraw(amount)
    raise(ArgumentError, 'Amount must be positive') unless amount.positive?

    with_lock do
      self.amount -= amount
      save!
    end
  end

  def deposit(amount)
    raise(ArgumentError, 'Amount must be positive') unless amount.positive?

    with_lock do
      self.amount += amount
      save!
    end
  end

  def today_change
    to_transactions.today.sum(:amount) - from_transactions.today.sum(:amount)
  end

  def transactions
    to_transaction_ids = to_transactions.pluck(:id)
    frozen_to_transaction_ids = to_transactions.where(status: 'frozen').pluck(:id)
    from_transactions.or(Transaction.where(id: to_transaction_ids - frozen_to_transaction_ids)).distinct
  end
end

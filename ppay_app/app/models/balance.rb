# frozen_string_literal: true

class Balance < ApplicationRecord
  has_many :from_transactions, class_name: 'Transaction', foreign_key: :from_balance_id
  has_many :to_transactions, class_name: 'Transaction', foreign_key: :to_balance_id

  belongs_to :balanceable, polymorphic: true

  validates :amount, numericality: { greater_than_or_equal_to: 0 }

  def withdraw(amount, national_currency_amount)
    with_lock do
      self.amount -= if in_national_currency
                       national_currency_amount
                     else
                       amount
                     end
      save!
    end
  end

  def deposit(amount, national_currency_amount)
    with_lock do
      self.amount += if in_national_currency
                       national_currency_amount
                     else
                       amount
                     end
      save!
    end
  end

  def today_change
    to_transactions.payment_transactions.today.completed.sum(amount_type) -
      from_transactions.payment_transactions.today.completed.sum(amount_type)
  end

  def transactions
    from_transactions.or(to_transactions.except(to_transactions.frozen))
  end

  private

  def amount_type
    in_national_currency ? :national_currency_amount : :amount
  end
end

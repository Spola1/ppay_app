# frozen_string_literal: true

class Balance < ApplicationRecord
  has_many :from_transactions, class_name: 'Transaction', foreign_key: :from_balance_id
  has_many :to_transactions, class_name: 'Transaction', foreign_key: :to_balance_id

  belongs_to :balanceable, polymorphic: true

  validates :amount, numericality: { greater_than_or_equal_to: 0 }

  def withdraw(amount)
    self.with_lock do
      self.amount -= amount
      save!
    end
  end

  def deposit(amount)
    self.with_lock do
      self.amount += amount
      save!
    end
  end
end

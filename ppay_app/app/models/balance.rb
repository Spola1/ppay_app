# frozen_string_literal: true

class Balance < ApplicationRecord
  has_many :from_transactions, class_name: 'Transaction', foreign_key: :from_balance_id
  has_many :to_transactions, class_name: 'Transaction', foreign_key: :to_balance_id

  belongs_to :balanceable, polymorphic: true
end

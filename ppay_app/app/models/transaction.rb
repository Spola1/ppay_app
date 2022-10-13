# frozen_string_literal: true

class Transaction < ApplicationRecord
  belongs_to :from_balance, class_name: 'Balance'
  belongs_to :to_balance, class_name: 'Balance'
  belongs_to :payment
end

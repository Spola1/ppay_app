# frozen_string_literal: true

class PaymentSystem < ApplicationRecord
  has_many :commissions
  has_many :merchants, through: :commissions
  has_many :rate_snapshots

  belongs_to :payment_system_copy, class_name: 'PaymentSystem', optional: true
  belongs_to :national_currency
end

# frozen_string_literal: true

class PaymentSystem < ApplicationRecord
  has_many :merchant_methods, dependent: :destroy
  has_many :commissions, through: :merchant_methods
  has_many :merchants, through: :merchant_methods
  has_many :rate_snapshots, dependent: :destroy

  belongs_to :payment_system_copy, class_name: 'PaymentSystem', optional: true
  belongs_to :national_currency
  belongs_to :exchange_portal
end

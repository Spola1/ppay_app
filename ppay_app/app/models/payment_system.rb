# frozen_string_literal: true

class PaymentSystem < ApplicationRecord
  has_many :commissions
  has_many :merchants, through: :commissions
  belongs_to :national_currency

  validates :name, uniqueness: true
end

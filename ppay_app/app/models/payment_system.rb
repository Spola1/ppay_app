# frozen_string_literal: true

class PaymentSystem < ApplicationRecord
  has_many :commissions
  has_many :merchants, through: :commissions

  validates :name, uniqueness: true
end

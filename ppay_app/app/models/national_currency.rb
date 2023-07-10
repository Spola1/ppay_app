# frozen_string_literal: true

class NationalCurrency < ApplicationRecord
  has_many :payment_systems
  belongs_to :default_payment_system, class_name: 'PaymentSystem', optional: true

  validates :name, uniqueness: true
end

# frozen_string_literal: true

class PaymentSystem < ApplicationRecord
  validates :name, uniqueness: true
end

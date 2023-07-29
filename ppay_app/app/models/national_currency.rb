# frozen_string_literal: true

class NationalCurrency < ApplicationRecord
  has_many :payment_systems, -> { order(id: :asc) }

  validates :name, uniqueness: true
end

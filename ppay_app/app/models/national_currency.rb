# frozen_string_literal: true

class NationalCurrency < ApplicationRecord
  validates :name, uniqueness: true
end

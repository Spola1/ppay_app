# frozen_string_literal: true

class FormCustomization < ApplicationRecord
  belongs_to :merchant
  belongs_to :payment
  has_one_attached :logo
end

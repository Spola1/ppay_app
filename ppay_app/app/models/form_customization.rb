# frozen_string_literal: true

class FormCustomization < ApplicationRecord
  belongs_to :merchant
  has_one_attached :logo
end

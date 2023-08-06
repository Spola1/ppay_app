# frozen_string_literal: true

class PaymentReceipt < ApplicationRecord
  belongs_to :payment
  has_one_attached :image
end

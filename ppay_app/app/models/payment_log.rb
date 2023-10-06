# frozen_string_literal: true

class PaymentLog < ApplicationRecord
  belongs_to :payment
end

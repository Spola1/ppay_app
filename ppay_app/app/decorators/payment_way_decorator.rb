# frozen_string_literal: true

class PaymentWayDecorator < ApplicationDecorator
  delegate_all

  def name
    "#{payment_system.name} #{national_currency.name}"
  end
end

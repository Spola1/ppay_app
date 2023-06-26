# frozen_string_literal: true

class PaymentSystemDecorator < ApplicationDecorator
  delegate_all

  def full_name
    "#{name} #{national_currency.name}"
  end
end

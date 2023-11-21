# frozen_string_literal: true

class PaymentSystemDecorator < ApplicationDecorator
  delegate_all

  def full_name
    "#{name} #{national_currency.name}"
  end

  def sell_rate
    latest_sell_rate_snapshot&.value
  end

  def buy_rate
    latest_buy_rate_snapshot&.value
  end
end

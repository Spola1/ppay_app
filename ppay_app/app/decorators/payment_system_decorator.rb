# frozen_string_literal: true

class PaymentSystemDecorator < ApplicationDecorator
  delegate_all

  def full_name
    "#{name} #{national_currency.name}"
  end

  def sell_rate
    rate_snapshots.sell.last&.value
  end

  def buy_rate
    rate_snapshots.buy.last&.value
  end
end

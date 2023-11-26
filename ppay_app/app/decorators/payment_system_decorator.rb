# frozen_string_literal: true

class PaymentSystemDecorator < ApplicationDecorator
  delegate_all

  def full_name
    "#{name} #{national_currency.name}"
  end

  def sell_rate
    rate_payment_system.rate_snapshots.sell.last&.value
  end

  def buy_rate
    rate_payment_system.rate_snapshots.buy.last&.value
  end

  private

  def rate_payment_system
    payment_system_copy || self
  end
end

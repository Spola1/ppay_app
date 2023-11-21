# frozen_string_literal: true

class MerchantMethodDecorator < UserDecorator
  delegate_all

  RATE_TYPES = {
    'Deposit' => :buy,
    'Withdrawal' => :sell
  }.freeze

  def commission_percentage
    commissions.sum { _1.commission_type.in?(%w[agent other]) ? _1.commission : 0 }
  end

  def rate
    payment_system.decorate.public_send("#{rate_type}_rate")
  end

  def name
    "#{payment_system.name} #{national_currency.name} #{direction}"
  end

  private

  def rate_type
    RATE_TYPES[direction]
  end
end

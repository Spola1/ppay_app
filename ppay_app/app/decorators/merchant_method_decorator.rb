# frozen_string_literal: true

class MerchantMethodDecorator < UserDecorator
  delegate_all

  delegate :name, to: :payment_system, prefix: true

  RATE_TYPES = {
    'Deposit' => :buy,
    'Withdrawal' => :sell
  }.freeze

  def commission_percentage
    commissions.where(commission_type: %i[agent other]).sum(:commission)
  end

  def rate
    payment_system.decorate.public_send("#{rate_type}_rate")
  end

  def currency
    payment_system.national_currency.name
  end

  private

  def rate_type
    RATE_TYPES[direction]
  end
end

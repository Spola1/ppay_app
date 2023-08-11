# frozen_string_literal: true

class BalanceDecorator < ApplicationDecorator
  delegate_all

  def amount_formatted
    formatted_amount(amount)
  end

  def frozen_amount_formatted
    formatted_amount(from_transactions.payment_transactions.frozen.sum(:amount))
  end

  def today_income_formatted
    formatted_amount(to_transactions.today.payment_transactions.processer_commission.completed.sum(:amount))
  end
end

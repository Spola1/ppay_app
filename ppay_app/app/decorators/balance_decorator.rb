# frozen_string_literal: true

class BalanceDecorator < ApplicationDecorator
  delegate_all

  def amount_formatted
    formatted_amount(amount)
  end
end

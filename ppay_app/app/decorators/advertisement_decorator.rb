# frozen_string_literal: true

class AdvertisementDecorator < ApplicationDecorator
  delegate_all

  def formatted_card_number
    card_number&.gsub(/(.{4})/, '\1 ')
  end

  def card_info
    truncated_payment_system = payment_system.length <= 8 ? "#{payment_system}**" : "#{payment_system.delete(' ')[0..7]}**"
    "#{truncated_payment_system.upcase}#{card_number[-4..]}"
  end

  def hotlist_payments
    direction == 'Deposit' ? payments.in_deposit_flow_hotlist : payments.in_withdrawal_flow_hotlist
  end

  def active_status
    if status
      if exceed_daily_usdt_card_limit?
        'Превышен суточный лимит'
      else
        'Активно'
      end
    else
      'Неактивно'
    end
  end
end

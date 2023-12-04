# frozen_string_literal: true

class AdvertisementDecorator < ApplicationDecorator
  delegate_all

  def formatted_card_number
    card_number&.gsub(/(.{4})/, '\1 ')
  end

  def card_tail
    card_number&.[](-4..)
  end

  def card_info
    truncated_payment_system =
      payment_system.length <= 8 ? "#{payment_system}**" : "#{payment_system.delete(' ')[0..7]}**"
    "#{truncated_payment_system.upcase}#{card_tail}"
  end

  def hotlist_payments
    direction == 'Deposit' ? payments.in_deposit_flow_hotlist : payments.in_withdrawal_flow_hotlist
  end

  def block_reason_presentation
    Advertisement.human_attribute_name("block_reason.#{block_reason}") if block_reason
  end
end

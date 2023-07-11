# frozen_string_literal: true

class AdvertisementDecorator < ApplicationDecorator
  delegate_all

  def formatted_card_number
    card_number&.gsub(/(.{4})/, '\1 ')
  end

  def card_info
    "#{payment_system} #{card_number[-4..-1]}"
  end
end

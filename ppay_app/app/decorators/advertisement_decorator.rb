# frozen_string_literal: true

class AdvertisementDecorator < ApplicationDecorator
  delegate_all

  def formatted_card_number
    card_number&.gsub(/(.{4})/, '\1 ')
  end
end

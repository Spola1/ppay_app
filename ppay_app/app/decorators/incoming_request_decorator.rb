# frozen_string_literal: true

class IncomingRequestDecorator < ApplicationDecorator
  delegate_all

  def formatted_uuid
    return unless payment

    "#{payment.uuid[0..4]}...#{payment.uuid[-3..-1]}".upcase
  end

  def formatted_card_number
    return unless advertisement

    advertisement.card_number[-4..-1]
  end
end

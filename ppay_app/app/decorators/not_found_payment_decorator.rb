# frozen_string_literal: true

class NotFoundPaymentDecorator < ApplicationDecorator
  delegate_all

  def formatted_status_created_at
    formatted_date(created_at)
  end

  def national_formatted
    formatted_amount(parsed_amount)
  end
end

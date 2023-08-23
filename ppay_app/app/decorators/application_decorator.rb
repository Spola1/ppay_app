# frozen_string_literal: true

class ApplicationDecorator < Draper::Decorator
  def formatted_created_at
    formatted_date(created_at)
  end

  def formatted_created_at_moscow
    formatted_date(created_at.in_time_zone('Moscow'))
  end

  def formatted_started_arbitration_at
    if arbitration_resolutions.last&.ended_at.present?
      nil
    else
      formatted_date(arbitration_resolutions.last&.created_at)
    end

    #debugger
  end

  private

  def formatted_date(date)
    l(date, format: :short) if date
  end

  def formatted_amount(amount)
    format('%.2f', amount) if amount
  end
end

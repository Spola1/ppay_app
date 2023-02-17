# frozen_string_literal: true

class ApplicationDecorator < Draper::Decorator
  def formatted_created_at
    formatted_date(created_at)
  end

  def formatted_created_at_moscow
    formatted_date(created_at.in_time_zone("Moscow"))
  end

  private

  def formatted_date(date)
    l(date, format: :short) if date
  end
end

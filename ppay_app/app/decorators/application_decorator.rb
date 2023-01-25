class ApplicationDecorator < Draper::Decorator
  def formatted_created_at
    formatted_date(created_at)
  end

  private

  def formatted_date(date)
    l(date, format: :short)
  end
end

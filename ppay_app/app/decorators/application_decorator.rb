class ApplicationDecorator < Draper::Decorator
  # Define methods for all decorated objects.
  # Helpers are accessed through `helpers` (aka `h`). For example:
  #
  #   def percent_amount
  #     h.number_to_percentage object.amount, precision: 2
  #   end

  private

  def formatted_date(date)
    date.in_time_zone("Moscow").strftime("%F %H:%M")
  end
end

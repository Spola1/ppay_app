module AuditsHelper
  FORMAT_MAPPING = { 'status_changed_at' => :formatted_date_string }.freeze

  def formatted_changes(attribute, values)
    formatted_values(attribute, values).join(' -> ')
  end

  def formatted_date_string(date)
    date.to_datetime.strftime('%Y-%m-%d %H:%M')
  end

  def verify_array(attribute, values)
    values.is_a?(Array) ? formatted_changes(attribute, values) : values
  end

  private

  def formatted_values(attribute, values)
    present_values = values.compact

    return present_values unless FORMAT_MAPPING[attribute]

    present_values.map do |value|
      public_send(FORMAT_MAPPING[attribute], value)
    end
  end
end
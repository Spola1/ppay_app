# frozen_string_literal: true

module JsonApiHelper
  def response_body
    JSON.parse(response.body).deep_symbolize_keys.with_indifferent_access
  rescue StandardError
    nil
  end
end

# frozen_string_literal: true

module JsonApiHelper
  def response_body
    JSON.parse(response.body)
  end
end

# frozen_string_literal: true

class UserDecorator < PaymentDecorator
  include Rails.application.routes.url_helpers

  delegate_all

  def human_type
    User.human_attribute_name("type.#{type.underscore}")
  end
end

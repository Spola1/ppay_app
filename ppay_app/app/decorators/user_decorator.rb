# frozen_string_literal: true

class UserDecorator < PaymentDecorator
  include Rails.application.routes.url_helpers

  delegate_all

  def human_type
    User.human_attribute_name("type.#{type.underscore}")
  end

  def audit_user_info
    "#{human_type} #{display_name} (#{display_email})"
  end

  def display_email
    email.to_s
  end

  def display_name
    nickname.presence || full_name || display_id
  end

  def full_name
    [name, surname].reject(&:blank?).join(' ').presence
  end

  def display_id
    "ID: #{id}"
  end
end

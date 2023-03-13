# frozen_string_literal: true

class UserDecorator < ApplicationDecorator
  delegate_all

  def human_type
    User.human_attribute_name("type.#{type.underscore}")
  end

  def audit_user_info
    "#{human_type} #{display_name} (#{email})"
  end

  def display_name
    nickname.presence || full_name.presence || display_id
  end

  def full_name
    [name, surname].reject(&:blank?).join(' ')
  end

  def display_id
    "ID: #{id}"
  end
end

# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  def navbar_collection
    Settings.navbar[current_user.type.underscore]
  end

  def hotlist_payments(user)
    user.payments.in_hotlist.decorate
  end

  def active?(name)
    name == action_name ? :active : nil
  end
end

# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  def navbar_collection
    Settings.navbar[current_user.type.underscore]
  end

  def hotlist_payments(user)
    user.payments.in_hotlist.decorate
  end
end

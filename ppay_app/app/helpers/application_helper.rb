# frozen_string_literal: true

module ApplicationHelper
  def navbar_collection
    Settings.navbar[current_user.type.underscore]
  end
end

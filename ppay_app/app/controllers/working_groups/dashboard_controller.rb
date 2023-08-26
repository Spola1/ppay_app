# frozen_string_literal: true

module WorkingGroups
  class DashboardController < Staff::DashboardController
    def processers_scope
      current_user.processers
    end
  end
end

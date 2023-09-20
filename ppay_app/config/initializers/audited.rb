# frozen_string_literal: true

Audited::Sweeper::STORED_DATA[:user_agent] = :user_agent

module Audited
  class Sweeper
    def user_agent
      controller.try(:request).try(:user_agent)
    end
  end
end

module Audited
  class Audit < ::ActiveRecord::Base
    before_create :set_user_agent

    def set_user_agent
      self.user_agent ||= ::Audited.store[:user_agent]
    end
  end
end

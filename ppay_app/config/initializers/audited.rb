# frozen_string_literal: true

Audited::Sweeper::STORED_DATA[:user_agent] = :user_agent
Audited::Sweeper::STORED_DATA[:bearer_user] = :bearer_user

module Audited
  class Sweeper
    def user_agent
      controller.try(:request).try(:user_agent)
    end

    def bearer_user
      lambda { controller.try(:current_bearer) }
    end
  end
end

module Audited
  class Audit < ::ActiveRecord::Base
    belongs_to :bearer_user, optional: true, polymorphic: true

    before_create do
      self.user_agent ||= ::Audited.store[:user_agent]
      self.bearer_user ||= ::Audited.store[:bearer_user].try!(:call)
    end
  end
end

module StateMachines
  module Payments
    module Base
      extend ActiveSupport::Concern

      private

      def update_status_changed_at
        self.status_changed_at = Time.zone.now
      end
    end
  end
end

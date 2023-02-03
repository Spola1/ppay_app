module Staff
  module BalanceRequests
    module EventFireable
      extend ActiveSupport::Concern

      included do
        helper_method :allowed_events
      end

      private

      def event
        allowed_events[params.dig(:balance_request, :status)] if params.dig(:balance_request, :status).present?
      end

      def fire_event
        @balance_request.aasm.fire!(event) if event
      end

      def allowed_events
        self.class::STATUS_EVENTS_MAPPING
      end
    end
  end
end

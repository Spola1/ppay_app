# frozen_string_literal: true

module Payments
  module Statuses
    class WithdrawalsController < StatusesController
      private

      def allowed_events
        %i[search confirm cancel]
      end

      def payment_params
        params.fetch(:withdrawal, {}).permit(:payment_system, :card_number)
      end
    end
  end
end

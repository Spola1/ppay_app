# frozen_string_literal: true

module Payments
  module Statuses
    class DepositsController < StatusesController
      private

      def allowed_events
        %i[search check cancel]
      end

      def payment_params
        params.fetch(:deposit, {}).permit(:payment_system, :image)
      end
    end
  end
end

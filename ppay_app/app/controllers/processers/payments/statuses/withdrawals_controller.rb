# frozen_string_literal: true

module Processers
  module Payments
    module Statuses
      class WithdrawalsController < StatusesController
        private

        def allowed_events
          %i[check cancel]
        end

        def payment_params
          params.fetch(:withdrawal, {}).permit(:image)
        end
      end
    end
  end
end

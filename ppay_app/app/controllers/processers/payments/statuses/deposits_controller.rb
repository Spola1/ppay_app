# frozen_string_literal: true

module Processers
  module Payments
    module Statuses
      class DepositsController < StatusesController
        private

        def allowed_events
          %i[confirm]
        end
      end
    end
  end
end

# frozen_string_literal: true

module Processers
  module Payments
    class DepositsController < PaymentsController

      def index
        @payments = Deposit.all.decorate
      end

      def show
      end

      private

      def allowed_events
        %i[confirm]
      end
    end
  end
end

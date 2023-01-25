# frozen_string_literal: true

module Supports
  module Payments
    class DepositsController < PaymentsController

      def index
        @payments = Deposit.all.decorate
      end

      def show
      end

      private

      def allowed_events
        []
      end
    end
  end
end

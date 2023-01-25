# frozen_string_literal: true

module Supports
  module Payments
    class WithdrawalsController < PaymentsController

      def index
        @payments = Withdrawal.all.decorate
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

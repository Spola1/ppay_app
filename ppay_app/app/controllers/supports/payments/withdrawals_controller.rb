# frozen_string_literal: true

module Supports
  module Payments
    class WithdrawalsController < PaymentsController
      def index
        @pagy, @payments = pagy(Withdrawal.all)
        @payments = @payments.decorate
      end

      private

      def required_params
        params.require(:withdrawal)
      end
    end
  end
end

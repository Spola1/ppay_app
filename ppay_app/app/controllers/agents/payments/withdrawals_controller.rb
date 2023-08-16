# frozen_string_literal: true

module Agents
  module Payments
    class WithdrawalsController < PaymentsController
      def index
        @pagy, @payments = pagy(Withdrawal.all)
        @payments = @payments.decorate
      end

      def show; end

      private

      def required_params
        params.require(:withdrawal)
      end
    end
  end
end

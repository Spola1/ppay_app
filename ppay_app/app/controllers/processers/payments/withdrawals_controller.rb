# frozen_string_literal: true

module Processers
  module Payments
    class WithdrawalsController < PaymentsController

      def index
        @payments = Withdrawal.all.decorate
      end

      def show
      end

      private

      def required_params
        params.require(:withdrawal)
      end
    end
  end
end

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

      def allowed_events
        %i[check]
      end

      def payment_params
        params.fetch(:withdrawal, {}).permit(:image)
      end
    end
  end
end

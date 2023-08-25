# frozen_string_literal: true

module Processers
  module Payments
    class DepositsController < PaymentsController
      def index
        @pagy, @payments = pagy(Deposit.all)
        @payments = @payments.decorate
      end

      def show
        mark_messages_as_read(@payment.comments)
        mark_messages_as_read(@payment.chats)
      end

      private

      def required_params
        params.require(:deposit)
      end
    end
  end
end

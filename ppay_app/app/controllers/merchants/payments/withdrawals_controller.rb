# frozen_string_literal: true

module Merchants
  module Payments
    class WithdrawalsController < PaymentsController
      def index
        @pagy, @payments = pagy(current_user.withdrawals)
        @payments = @payments.decorate
      end
    end
  end
end

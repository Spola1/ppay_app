# frozen_string_literal: true

module Merchants
  module Payments
    class WithdrawalsController < PaymentsController
      def index
        @payments = current_user.withdrawals.decorate
      end
    end
  end
end

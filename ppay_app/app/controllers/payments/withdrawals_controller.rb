# frozen_string_literal: true

module Payments
  class WithdrawalsController < PaymentsController
    def index
      @pagy, @payments = pagy(Withdrawal.all)
    end
  end
end

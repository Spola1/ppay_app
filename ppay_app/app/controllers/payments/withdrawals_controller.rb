# frozen_string_literal: true

module Payments
  class WithdrawalsController < PaymentsController
    def index
      @payments = Withdrawal.all
    end
  end
end

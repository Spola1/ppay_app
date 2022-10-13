# frozen_string_literal: true

module Payments
  class DepositsController < PaymentsController
    def index
      @payments = Deposit.all
    end

    private

    def payment_params
      params.fetch(:deposit, {}).permit(:payment_system, :image)
    end
  end
end

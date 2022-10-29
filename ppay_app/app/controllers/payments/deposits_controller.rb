# frozen_string_literal: true

module Payments
  class DepositsController < PaymentsController
    def index
      @payments = Deposit.all
    end

    private

    def allowed_events
      %i[search check cancel]
    end

    def payment_params
      params.fetch(:deposit, {}).permit(:payment_system, :image)
    end
  end
end

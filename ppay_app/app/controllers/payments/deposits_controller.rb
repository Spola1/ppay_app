# frozen_string_literal: true

module Payments
  class DepositsController < PaymentsController
    def index
      @pagy, @payments = pagy(Deposit.all)
    end
  end
end

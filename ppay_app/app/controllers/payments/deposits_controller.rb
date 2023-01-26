# frozen_string_literal: true

module Payments
  class DepositsController < PaymentsController
    def index
      @payments = Deposit.all
    end
  end
end

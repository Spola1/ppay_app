# frozen_string_literal: true

module Processers
  module Payments
    class DepositsController < PaymentsController
      def index
        @payments = Deposit.all.decorate
      end
    end
  end
end

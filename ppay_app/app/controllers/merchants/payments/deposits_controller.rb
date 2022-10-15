# frozen_string_literal: true

module Merchants
  module Payments
    class DepositsController < PaymentsController
      def index
        @payments = current_user.deposits.decorate
      end
    end
  end
end

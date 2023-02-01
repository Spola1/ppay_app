# frozen_string_literal: true

module Merchants
  module Payments
    class DepositsController < PaymentsController
      def index
        @pagy, @payments = pagy(current_user.deposits)
        @payments = @payments.decorate
      end
    end
  end
end

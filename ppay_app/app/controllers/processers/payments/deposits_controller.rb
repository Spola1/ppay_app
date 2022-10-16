# frozen_string_literal: true

module Processers
  module Payments
    class DepositsController < PaymentsController
      include ::Payments::Updateable

      def index
        @payments = Deposit.all.decorate
      end

      private

      def allowed_events
        %i[confirm]
      end

      def after_update_success
        redirect_to payments_path
      end

      def after_update_error
        redirect_to payments_path
      end
    end
  end
end

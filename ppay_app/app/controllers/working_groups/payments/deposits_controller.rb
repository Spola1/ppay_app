# frozen_string_literal: true

module WorkingGroups
  module Payments
    class DepositsController < PaymentsController
      def index
        @pagy, @payments = pagy(Deposit.where(processers: { working_group_id: current_user }))
        @payments = @payments.decorate
      end

      def show; end

      private

      def required_params
        params.require(:deposit)
      end
    end
  end
end

# frozen_string_literal: true

module WorkingGroups
  module Payments
    class WithdrawalsController < PaymentsController
      def index
        @pagy, @payments = pagy(Withdrawl.where(processers: { working_group_id: current_user }))
        @payments = @payments.decorate
      end

      def show; end

      private

      def required_params
        params.require(:withdrawal)
      end
    end
  end
end

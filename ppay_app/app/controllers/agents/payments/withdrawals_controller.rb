# frozen_string_literal: true

module Agents
  module Payments
    class WithdrawalsController < PaymentsController
      def index
        @pagy, @payments = pagy(Withdrawal.joins(merchant: :agent).where(users: { agent_id: current_user }))
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

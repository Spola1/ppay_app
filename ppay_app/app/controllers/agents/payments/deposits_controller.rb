# frozen_string_literal: true

module Agents
  module Payments
    class DepositsController < PaymentsController
      def index
        @pagy, @payments = pagy(Deposit.joins(merchant: :agent).where(users: { agent_id: current_user }))
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

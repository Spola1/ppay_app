# frozen_string_literal: true

module Payments
  module Transactions
    module Base
      private

      def merchant_commissions
        @merchant_commissions ||=
          merchant.commissions
                  .where(
                    direction: type,
                    payment_system: PaymentSystem.find_by(name: payment_system),
                    national_currency:
                  )
      end

      def processer_commission
        merchant_commissions.processer.first.commission
      end

      def working_group_commission
        merchant_commissions.working_group.first.commission
      end

      def agent_commission
        merchant_commissions.agent.first.commission
      end

      def ppay_commission
        merchant_commissions.ppay.first.commission
      end

      def complete_transactions
        transactions.each(&:complete!)
      end

      def cancel_transactions
        transactions.each(&:cancel!)
      end
    end
  end
end

module Payments
  module Transactions
    module Base
      private

      def processer_commission
        advertisement.processer.deposit_commission || 1
      end

      def working_group_commission
        advertisement.processer.working_group&.deposit_commission || 0
      end

      def agent_commission
        merchant.agent&.deposit_commission || 0
      end

      def ppay_commission
        Settings.ppay_commission
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
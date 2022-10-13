module Payments
  module Transactions
    module Deposit
      private

      def create_transactions
        create_main_transaction
        create_advertisement_transaction
        create_working_group_transaction
        create_agent_transaction
        create_ppay_transaction
      end

      def advertisement_commission
        advertisement.percent
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

      def main_transaction_amount
        cryptocurrency_amount * main_transaction_percent / 100
      end

      def main_transaction_percent
        100 - advertisement_commission - working_group_commission - agent_commission - ppay_commission
      end

      def create_main_transaction
        transactions.create(from_balance: advertisement.processer.balance,
                            to_balance: merchant.balance,
                            amount: main_transaction_amount)
      end

      def create_advertisement_transaction
        transactions.create(from_balance: advertisement.processer.balance,
                            to_balance: advertisement.processer.balance,
                            amount: cryptocurrency_amount * advertisement_commission / 100)
      end

      def create_working_group_transaction
        return if working_group_commission == 0

        transactions.create(from_balance: advertisement.processer.balance,
                            to_balance: advertisement.processer.working_group.balance,
                            amount: cryptocurrency_amount * advertisement_commission / 100)
      end

      def create_agent_transaction
        return if agent_commission == 0

        transactions.create(from_balance: advertisement.processer.balance,
                            to_balance: merchant.agent.balance,
                            amount: cryptocurrency_amount * agent_commission / 100)
      end

      def create_ppay_transaction
        transactions.create(from_balance: advertisement.processer.balance,
                            to_balance: Ppay.last.balance,
                            amount: cryptocurrency_amount * ppay_commission / 100)
      end

      def complete_transactions
        transactions.each(&:complete!)
      end
    end
  end
end
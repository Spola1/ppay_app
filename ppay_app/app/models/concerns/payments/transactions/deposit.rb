module Payments
  module Transactions
    module Deposit
      include Base

      private

      def create_transactions
        create_main_transaction
        create_advertisement_transaction
        create_working_group_transaction
        create_agent_transaction
        create_ppay_transaction
      end

      def create_main_transaction
        transactions.create(from_balance: advertisement.processer.balance,
                            to_balance: advertisement.processer.balance,
                            amount: main_transaction_amount)
      end

      def create_advertisement_transaction
        return if advertisement_commission == 0

        transactions.create(from_balance: advertisement.processer.balance,
                            to_balance: advertisement.processer.balance,
                            amount: cryptocurrency_amount * advertisement_commission / 100,
                            transaction_type: :advertisement_commission)
      end

      def create_working_group_transaction
        return if working_group_commission == 0

        transactions.create(from_balance: advertisement.processer.balance,
                            to_balance: advertisement.processer.working_group.balance,
                            amount: cryptocurrency_amount * advertisement_commission / 100,
                            transaction_type: :working_group_commission)
      end

      def create_agent_transaction
        return if agent_commission == 0

        transactions.create(from_balance: advertisement.processer.balance,
                            to_balance: merchant.agent.balance,
                            amount: cryptocurrency_amount * agent_commission / 100,
                            transaction_type: :agent_commission)
      end

      def create_ppay_transaction
        return if ppay_commission == 0

        transactions.create(from_balance: advertisement.processer.balance,
                            to_balance: Ppay.last.balance,
                            amount: cryptocurrency_amount * ppay_commission / 100,
                            transaction_type: :ppay_commission)
      end

      def main_transaction_amount
        cryptocurrency_amount * main_transaction_percent / 100
      end

      def main_transaction_percent
        100 - advertisement_commission - working_group_commission - agent_commission - ppay_commission
      end
    end
  end
end
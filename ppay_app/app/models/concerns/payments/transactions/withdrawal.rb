# frozen_string_literal: true

module Payments
  module Transactions
    module Withdrawal
      include Base

      def full_cryptocurrency_amount
        cryptocurrency_amount * full_percent / 100
      end

      def full_national_currency_amount
        national_currency_amount * full_percent / 100
      end

      private

      def create_transactions
        create_main_transaction
        create_processer_transaction
        create_working_group_transaction
        create_agent_transaction
        create_ppay_transaction
      end

      def create_main_transaction
        transactions.create(from_balance: merchant.balance,
                            to_balance: advertisement.processer.balance,
                            amount: cryptocurrency_amount,
                            national_currency_amount:)
      end

      def create_processer_transaction
        return if processer_commission.zero?

        prepare_processer_transaction
      end

      def prepare_processer_transaction
        transactions.create(
          from_balance: merchant.balance,
          to_balance: advertisement.processer.balance,
          amount: processer_amount,
          national_currency_amount: processer_national_currency_amount,
          transaction_type: :processer_commission
        )
      end

      def processer_amount
        cryptocurrency_amount * processer_commission / 100
      end

      def processer_national_currency_amount
        national_currency_amount * processer_commission / 100
      end

      def create_working_group_transaction
        return if working_group_commission.zero?

        transactions.create(from_balance: merchant.balance,
                            to_balance: to_working_group_balance,
                            amount: cryptocurrency_amount * working_group_commission / 100,
                            national_currency_amount: national_currency_amount * working_group_commission / 100,
                            transaction_type: :working_group_commission)
      end

      def to_working_group_balance
        advertisement.processer.working_group&.balance || Ppay.last.balance
      end

      def create_agent_transaction
        return if agent_commission.zero?

        transactions.create(from_balance: merchant.balance,
                            to_balance: to_agent_balance,
                            amount: cryptocurrency_amount * agent_commission / 100,
                            national_currency_amount: national_currency_amount * agent_commission / 100,
                            transaction_type: :agent_commission)
      end

      def to_agent_balance
        merchant.agent&.balance || Ppay.last.balance
      end

      def create_ppay_transaction
        return if ppay_commission.zero?

        transactions.create(from_balance: merchant.balance,
                            to_balance: Ppay.last.balance,
                            amount: cryptocurrency_amount * ppay_commission / 100,
                            national_currency_amount: national_currency_amount * ppay_commission / 100,
                            transaction_type: :ppay_commission)
      end

      def full_percent
        100 + processer_commission + working_group_commission + agent_commission + ppay_commission
      end

      def processer_commission
        processer.processer_withdrawal_commission
      end

      def working_group_commission
        processer.working_group_withdrawal_commission
      end
    end
  end
end

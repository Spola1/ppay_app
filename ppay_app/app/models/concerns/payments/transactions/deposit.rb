# frozen_string_literal: true

module Payments
  module Transactions
    module Deposit
      include Base

      private

      def create_transactions
        create_main_transaction
        create_processer_transaction
        create_working_group_transaction
        create_agent_transaction
        create_ppay_transaction
      end

      def freeze_balance
        create_freeze_balance_transaction
      end

      def create_freeze_balance_transaction
        return if merchant.balance_freeze_type.nil?

        transactions.create(
          from_balance: merchant.balance,
          to_balance: merchant.balance,
          amount: freeze_crypto_amount,
          national_currency_amount: freeze_national_currency_amount,
          transaction_type: :freeze_balance
        )
      end

      def freeze_crypto_amount
        if merchant.balance_freeze_type == 'short'
          main_transaction_amount
        else
          main_transaction_amount * merchant.long_freeze_percentage / 100
        end
      end

      def freeze_national_currency_amount
        if merchant.balance_freeze_type == 'short'
          national_currency_transaction_amount
        else
          national_currency_transaction_amount * merchant.long_freeze_percentage / 100
        end
      end

      def create_main_transaction
        transactions.create(from_balance: advertisement.processer.balance,
                            to_balance: merchant.balance,
                            amount: main_transaction_amount,
                            national_currency_amount: national_currency_transaction_amount)
      end

      def create_processer_transaction
        return if processer_commission.zero?

        prepare_processer_transaction
      end

      def prepare_processer_transaction
        transactions.create(
          from_balance: advertisement.processer.balance,
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

        transactions.create(from_balance: advertisement.processer.balance,
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

        transactions.create(from_balance: advertisement.processer.balance,
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

        prepare_ppay_transaction
      end

      def prepare_ppay_transaction
        transactions.create(
          from_balance: advertisement.processer.balance,
          to_balance: Ppay.last.balance,
          amount: ppay_amount,
          national_currency_amount: ppay_national_currency_amount,
          transaction_type: :ppay_commission
        )
      end

      def ppay_amount
        cryptocurrency_amount * ppay_commission / 100
      end

      def ppay_national_currency_amount
        national_currency_amount * ppay_commission / 100
      end

      def main_transaction_amount
        cryptocurrency_amount * main_transaction_percent / 100
      end

      def national_currency_transaction_amount
        national_currency_amount * main_transaction_percent / 100
      end

      def main_transaction_percent
        100 - processer_commission - working_group_commission - agent_commission - ppay_commission
      end
    end
  end
end

# frozen_string_literal: true

module Payments
  module Transactions
    module Base
      def available_cancelled_transactions?
        transactions.present? && transactions.pluck(:status).all?('cancelled')
      end

      def processer_commission
        processer.processer_commission
      end

      def working_group_commission
        processer.working_group_commission
      end

      def agent_commission
        merchant_commissions.agent.first.commission
      end

      def other_commission
        merchant_commissions.other.first.commission
      end

      def ppay_commission
        [
          other_commission - processer_commission - working_group_commission,
          0
        ].max
      end

      private

      def merchant_commissions
        @merchant_commissions ||=
          merchant.commissions.where(
            merchant_methods:
              {
                direction: type,
                payment_system: PaymentSystem.find_by(
                  {
                    name: payment_system.presence || rate_snapshot.payment_system.name,
                    national_currency: NationalCurrency.find_by(name: national_currency)
                  }
                )
              }
          )
      end

      def complete_transactions
        transactions.where.not(transaction_type: :freeze_balance).each(&:complete!)
      end

      def cancel_transactions
        transactions.each(&:cancel!)
      end

      def restore_transactions
        transactions.each(&:restore!)
      end

      def calculate_unfreeze_time
        if merchant.balance_freeze_type == 'short'
          Time.now + merchant.short_freeze_days.days
        else
          Time.now + merchant.long_freeze_days.days
        end
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
    end
  end
end

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
    end
  end
end

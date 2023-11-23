# frozen_string_literal: true

module Payments
  module Transactions
    module Base
      def available_cancelled_transactions?
        transactions.payment_transactions.present? &&
          transactions.payment_transactions.pluck(:status).all?('cancelled')
      end

      def available_frozen_transactions?
        transactions.payment_transactions.present? &&
          transactions.payment_transactions.pluck(:status).all?('frozen')
      end

      def available_completed_transactions?
        transactions.payment_transactions.present? &&
          transactions.payment_transactions.pluck(:status).all?('completed')
      end

      def transactions_rollbackable?
        available_completed_transactions? &&
          transactions.payment_transactions.all? { |tr| (tr.to_balance&.amount || 0) >= tr.amount }
      end

      def processer_commission
        processer&.processer_commission || 0
      end

      def working_group_commission
        processer&.working_group_commission || 0
      end

      def agent_commission
        merchant_commissions.agent&.first&.commission || 0
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

      def total_commission
        processer_commission + working_group_commission + agent_commission + ppay_commission
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
                    name: payment_system.presence || merchant.payment_systems.sample.name,
                    national_currency: NationalCurrency.find_by(name: national_currency)
                  }
                )
              }
          )
      end

      def complete_transactions
        transactions.payment_transactions.each(&:complete!)
      end

      def cancel_transactions
        transactions.payment_transactions.each(&:cancel!)
      end

      def restore_transactions
        transactions.payment_transactions.each(&:restore!)
      end

      def rollback_transactions
        transactions.payment_transactions.each(&:rollback!)
      end

      def destroy_transactions
        transactions.cancelled.payment_transactions.each(&:destroy)
      end
    end
  end
end

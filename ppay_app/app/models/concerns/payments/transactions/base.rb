# frozen_string_literal: true

module Payments
  module Transactions
    module Base
      def available_cancelled_transactions?
        transactions.present? && transactions.pluck(:status).all?('cancelled')
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

      def processer_commission
        if Setting.instance.commissions_version == 2
          processer.processer_commission
        else
          merchant_commissions.processer.first.commission
        end
      end

      def working_group_commission
        if Setting.instance.commissions_version == 2
          processer.working_group_commission
        else
          merchant_commissions.working_group.first.commission
        end
      end

      def agent_commission
        merchant_commissions.agent.first.commission
      end

      def ppay_commission
        if Setting.instance.commissions_version == 2
          [
            merchant_commissions.other.first.commission - processer_commission - working_group_commission,
            0
          ].max
        else
          merchant_commissions.ppay.first.commission
        end
      end

      def complete_transactions
        transactions.each(&:complete!)
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

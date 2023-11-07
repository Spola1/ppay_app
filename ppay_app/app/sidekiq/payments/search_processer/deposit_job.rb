# frozen_string_literal: true

module Payments
  module SearchProcesser
    class DepositJob < Base
      private

      def selected_advertisement
        if payment.payment_system == 'СБП'
          Advertisement.for_deposit_with_sbp_payment_system(payment).first
        else
          Advertisement.for_deposit(payment).first
        end
      end
    end
  end
end

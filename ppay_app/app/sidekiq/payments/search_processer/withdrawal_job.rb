# frozen_string_literal: true

module Payments
  module SearchProcesser
    class WithdrawalJob < Base
      private

      def selected_advertisement
        Advertisement.for_withdrawal(payment)
                     .order_by_arbitration_and_confirming_payments
                     .order_by_similar_payments(payment.national_currency_amount)
                     .order_by_similar_payments_count(payment.national_currency_amount)
                     .first
      end
    end
  end
end

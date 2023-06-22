# frozen_string_literal: true

module Payments
  module SearchProcesser
    class DepositJob < Base
      private

      def selected_advertisement
        Advertisement.for_deposit(payment)
                     .order_by_arbitration_and_confirming_payments
                     .order_by_similar_payments(payment.national_currency_amount)
                     .order_by_similar_payments_count(payment.national_currency_amount)
                     .first
      end
    end
  end
end

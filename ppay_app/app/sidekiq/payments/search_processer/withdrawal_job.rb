# frozen_string_literal: true

module Payments
  module SearchProcesser
    class WithdrawalJob < Base
      private

      def selected_advertisement
        advertisements = Advertisement.for_payment(payment)
                                      .for_withdrawal
                                      .order_by_algorithm(payment.national_currency_amount)
      end
    end
  end
end

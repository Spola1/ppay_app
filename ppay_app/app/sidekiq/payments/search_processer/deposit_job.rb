# frozen_string_literal: true

module Payments
  module SearchProcesser
    class DepositJob < Base
      private

      def selected_advertisement
        advertisements = Advertisement.for_payment(payment)
                                      .for_deposit(payment.cryptocurrency_amount)
                                      .order_by_algorithm(payment.national_currency_amount)

        if advertisements.distinct.count == 1
          advertisements.order_by_remaining_confirmation_time.first
        else
          advertisements.order_by_algorithm(payment.national_currency_amount).sample
        end
      end
    end
  end
end

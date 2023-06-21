# frozen_string_literal: true

module Payments
  module SearchProcesser
    class DepositJob < Base
      private

      def selected_advertisement
        Advertisement.for_payment(payment)
                     .by_processer_balance(payment.cryptocurrency_amount)
                     .by_direction('Deposit')
                     .first
      end
    end
  end
end

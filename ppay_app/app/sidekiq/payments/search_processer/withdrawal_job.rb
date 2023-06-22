# frozen_string_literal: true

module Payments
  module SearchProcesser
    class WithdrawalJob < Base
      private

      def selected_advertisement
        Advertisement.for_payment(payment)
                     .by_direction('Withdrawal')
                     .first
      end
    end
  end
end

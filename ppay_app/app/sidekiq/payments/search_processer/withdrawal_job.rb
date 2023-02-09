# frozen_string_literal: true

module Payments
  module SearchProcesser
    class WithdrawalJob < Base
      private

      def selected_advertisement(payment)
        Advertisement.active
                     .by_payment_system(payment.payment_system)
                     .by_direction('Withdrawal')
                     .sample
      end
    end
  end
end

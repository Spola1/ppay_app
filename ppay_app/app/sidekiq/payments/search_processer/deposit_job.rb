# frozen_string_literal: true

module Payments
  module SearchProcesser
    class DepositJob < Base
      private

      def selected_advertisement(payment)
        Advertisement.active
                     .by_payment_system(payment.payment_system)
                     .by_processer_balance(payment.cryptocurrency_amount)
                     .by_direction('Deposit')
                     .sample
      end
    end
  end
end

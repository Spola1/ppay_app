# frozen_string_literal: true

module Payments
  module SearchProcesser
    class WithdrawalInteractor < BaseInteractor
      private

      def selected_advertisement
        Advertisement.for_withdrawal(payment).first
      end
    end
  end
end

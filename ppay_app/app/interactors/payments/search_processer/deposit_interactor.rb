# frozen_string_literal: true

module Payments
  module SearchProcesser
    class DepositInteractor < BaseInteractor
      private

      def selected_advertisement
        Advertisement.for_deposit(payment).first
      end
    end
  end
end

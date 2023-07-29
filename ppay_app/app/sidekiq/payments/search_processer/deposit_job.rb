# frozen_string_literal: true

module Payments
  module SearchProcesser
    class DepositJob < Base
      private

      def selected_advertisement
        Advertisement.for_deposit(payment).first
      end
    end
  end
end

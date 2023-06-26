# frozen_string_literal: true

module Payments
  module SearchProcesser
    class WithdrawalJob < Base
      private

      def selected_advertisement
        advertisements = Advertisement.for_withdrawal(payment)
                                    .order_by_transferring_and_confirming_payments
                                    .order_by_similar_payments(payment.national_currency_amount)
                                    .order_by_similar_payments_count(payment.national_currency_amount)

        if advertisements.distinct.count == 1
          # Все объявления имеют одинаковое количество одинаковых платежей
          advertisements.order_by_remaining_confirmation_time.first
        else
          # Найдено несколько объявлений с наименьшим количеством одинаковых платежей
          advertisements.order_by_similar_payments_count(payment.national_currency_amount).sample
        end
      end
    end
  end
end

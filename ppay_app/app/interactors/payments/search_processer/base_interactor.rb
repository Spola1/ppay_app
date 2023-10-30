# frozen_string_literal: true

module Payments
  module SearchProcesser
    class BaseInteractor
      include Interactor

      attr_reader :payment

      def call
        @payment = Payment.find(context.payment_id)

        if payment.advertisement.blank? && payment.processer_search?
          if selected_advertisement.present?
            existing_payment =
              selected_advertisement.payments
                                    .where(national_currency_amount: payment.national_currency_amount,
                                           national_currency: payment.national_currency,
                                           payment_status: 'processer_search')
                                    .where.not(uuid: payment.uuid)

            if existing_payment.blank? || existing_payment.size <= @payment.merchant.equal_amount_payments_limit
              payment.update(advertisement: selected_advertisement)
            else
              payment.update(advertisement_not_found_reason: :equal_amount_payments_limit_exceeded)
            end

          elsif payment.advertisements_available?
            payment.update(advertisement_not_found_reason: :equal_amount_payments_limit_exceeded)
          else
            payment.update(advertisement_not_found_reason: :no_active_advertisements)
          end

          payment.bind! if payment.advertisement
        end

        payment.bind! if payment.reload.processer_search? && payment.advertisement

        return unless payment.advertisement.blank?

        context.fail!(
          message: 'search_processer.no_advertisement',
          processer_search: payment.processer_search?
        )
      end
    end
  end
end

# frozen_string_literal: true

module Payments
  module SearchProcesser
    class BaseInteractor
      include Interactor

      attr_reader :payment

      def call
        @payment = Payment.find(context.payment_id)

        if payment.advertisement.blank? && payment.processer_search?
          payment.update(advertisement: selected_advertisement)
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

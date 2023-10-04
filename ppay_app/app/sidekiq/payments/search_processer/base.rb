# frozen_string_literal: true

module Payments
  module SearchProcesser
    class Base
      include Sidekiq::Job
      sidekiq_options queue: 'high', tags: ['search_processer']

      attr_reader :payment

      def perform(payment_id)
        @payment = Payment.find(payment_id)

        search_advertisment

        payment.bind! if payment.reload.processer_search? && payment.advertisement

        puts 'найден' if payment.advertisement.present?
      end

      private

      def search_advertisment
        start_time = Time.now

        while search_valid?(start_time)
          puts 'не найден'

          if selected_advertisement.present?
            payment.update(advertisement: selected_advertisement)
          elsif payment.advertisements_available?
            payment.update(advertisement_not_found_reason: :equal_amount_payments_limit_exceeded)
          else
            payment.update(advertisement_not_found_reason: :no_active_advertisements)
          end
          payment.bind! if payment.advertisement
          sleep 0.5
        end
      end

      def search_valid?(start_time)
        payment.reload.advertisement.blank? &&
          payment.reload.processer_search? &&
          (Time.now - start_time) < 600
      end
    end
  end
end

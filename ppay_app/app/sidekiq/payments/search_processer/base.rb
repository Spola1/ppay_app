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
        while payment.reload.advertisement.blank? && payment.reload.processer_search?
          puts 'не найден'
          payment.update(advertisement: selected_advertisement)
          payment.bind! if payment.advertisement
          sleep 0.5
        end
      end
    end
  end
end

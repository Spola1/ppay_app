# frozen_string_literal: true

module Payments
  module SearchProcesser
    class Base
      include Sidekiq::Job
      sidekiq_options queue: 'high', tags: ['search_processer']

      def perform(payment_id)
        payment = Payment.find(payment_id)

        search_advertisment(payment)

        payment.bind! if payment.reload.processer_search? && payment.advertisement

        puts 'найден' if payment.advertisement.present?
      end

      private

      def search_advertisment(payment)
        while payment.reload.advertisement.blank? && payment.reload.processer_search?
          puts 'не найден'
          payment.update(advertisement: selected_advertisement(payment))
          payment.bind! if payment.advertisement
          sleep 0.5
        end
      end
    end
  end
end

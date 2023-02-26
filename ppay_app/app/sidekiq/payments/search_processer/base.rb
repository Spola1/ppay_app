# frozen_string_literal: true

module Payments
  module SearchProcesser
    class Base
      include Sidekiq::Job
      sidekiq_options queue: 'high', tags: ['search_processer']

      def perform(payment_id)
        payment = Payment.find(payment_id)

        while payment.reload.advertisement.blank? && payment.reload.processer_search?
          puts 'не найден'
          payment.advertisement = selected_advertisement(payment)
          payment.bind!
          sleep 0.5
        end

        payment.bind! if payment.reload.processer_search?

        puts 'найден' if payment.advertisement.present?
      end
    end
  end
end

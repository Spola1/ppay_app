# frozen_string_literal: true

module Payments
  class SearchProcesserJob
    include Sidekiq::Job
    sidekiq_options queue: 'critical', tags: ['search_processer']

    def perform(payment_id)
      payment = Payment.find(payment_id)

      while payment.advertisement.blank? && payment.reload.processer_search? do
        puts 'не найден'
        payment.advertisement = Advertisement.active
                                             .by_payment_system(payment.payment_system)
                                             .by_amount(payment.national_currency_amount)
                                             .by_processer_balance(payment.cryptocurrency_amount)
                                             .sample
        sleep 0.5
      end

      puts 'найден' if payment.advertisement.present?
      payment.bind!
    end
  end
end

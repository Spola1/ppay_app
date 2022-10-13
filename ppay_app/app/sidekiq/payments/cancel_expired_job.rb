# frozen_string_literal: true

module Payments
  class CancelExpiredJob
    include Sidekiq::Job
    sidekiq_options queue: 'high', tags: ['cancel_expired']

    def perform
      Payment.waiting_for_payment.expired.find_each do |payment|
        payment.cancel!
        puts "Платёж #{payment.uuid} отменён"
      end
    end
  end
end

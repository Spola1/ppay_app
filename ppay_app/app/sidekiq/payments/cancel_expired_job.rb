# frozen_string_literal: true

module Payments
  class CancelExpiredJob
    include Sidekiq::Job
    sidekiq_options queue: 'low', tags: ['cancel_expired']

    def perform
      Payment.transferring.expired.find_each do |payment|
        payment.cancel!
        payment.update(cancellation_reason: 5)
        puts "Платёж #{payment.uuid} отменён"
      end
    end
  end
end

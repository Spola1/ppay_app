# frozen_string_literal: true

module Payments
  class CancelExpiredJob
    include Sidekiq::Job
    sidekiq_options queue: 'low', tags: ['cancel_expired']

    def perform
      Payment.transferring.expired
             .or(Payment.expired_arbitration_not_paid)
             .or(Payment.expired_autoconfirming)
             .find_each do |payment|
        payment.update(cancellation_reason: :time_expired)
        payment.cancel!
        puts "Платёж #{payment.uuid} отменён"
      end
    end
  end
end

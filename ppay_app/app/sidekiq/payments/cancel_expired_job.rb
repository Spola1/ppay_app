# frozen_string_literal: true

module Payments
  class CancelExpiredJob
    include Sidekiq::Job
    sidekiq_options queue: 'low', tags: ['cancel_expired']

    def perform
      cancel_expired
      cancel_expired_arbitration
      cancel_expired_autoconfirming
    end

    private

    def cancel_expired
      Payment.transferring.expired.find_each do |payment|
        payment.update(cancellation_reason: :time_expired)
        payment.cancel!
        puts "Платёж #{payment.uuid} отменён"
      end
    end

    def cancel_expired_arbitration
      Payment.expired_arbitration_not_paid.find_each do |payment|
        payment.update(cancellation_reason: :not_paid)
        payment.cancel!
        puts "Платёж #{payment.uuid} отменён"
      end
    end

    def cancel_expired_autoconfirming
      Payment.expired_autoconfirming.find_each do |payment|
        # payment.update(cancellation_reason: :not_paid)
        # payment.cancel!
        payment.update(autoconfirming: false)
        payment.comments.create(
          author_nickname: Settings.simbank_nickname,
          user_id: payment.processer.id,
          text: 'Ждал 3 минуты. Сумма не поступила. Перевожу на ручное подтверждение'
        )
        puts "Платёж #{payment.uuid} отменён"
      end
    end
  end
end

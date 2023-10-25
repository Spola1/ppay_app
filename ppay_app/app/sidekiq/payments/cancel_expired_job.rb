# frozen_string_literal: true

module Payments
  class CancelExpiredJob
    include Sidekiq::Job
    sidekiq_options queue: 'low', tags: ['cancel_expired']

    def perform
      cancel_expired
      cancel_arbitration_not_paid
      cancel_expired_autoconfirming
    end

    private

    def cancel_expired
      Deposit.transferring.expired.find_each do |payment|
        payment.update(cancellation_reason: :time_expired)
        payment.cancel!
        puts "Платёж #{payment.uuid} отменён"
      end
    end

    def cancel_arbitration_not_paid
      Deposit.arbitration_not_paid.find_each do |payment|
        payment.update(cancellation_reason: :not_paid)
        payment.cancel!
        payment.update(arbitration: false)
        puts "Платёж #{payment.uuid} отменён"
      end
    end

    def cancel_expired_autoconfirming
      Deposit.expired_autoconfirming.find_each do |payment|
        if payment.processer.autocancel
          payment.update(cancellation_reason: :not_paid)
          payment.cancel!
          text = "Ждал #{Setting.last.minutes_to_autocancel} минут. Сумма не поступила. Отменяю платеж"
        else
          payment.update(autoconfirming: false)
          text = "Ждал #{Setting.last.minutes_to_autocancel} минут. " \
                 'Сумма не поступила. Перевожу на ручное подтверждение'
        end
        payment.comments.create(
          author_nickname: Settings.simbank_nickname,
          user_id: payment.processer.id,
          text:,
          skip_notification: true
        )
        puts "Платёж #{payment.uuid} отменён"
      end
    end
  end
end

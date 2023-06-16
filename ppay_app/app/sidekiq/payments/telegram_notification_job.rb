# frozen_string_literal: true

module Payments
  class TelegramNotificationJob
    include Sidekiq::Job
    sidekiq_options queue: 'default', tags: ['payments_telegram_notification']

    def perform(payment_id)
      payment = Payment.find(payment_id)

      notify_service = TelegramNotification::ProcessersService.new(payment)

      notify_service.send_notification_to_user(payment.processer.telegram_id)
    end
  end
end

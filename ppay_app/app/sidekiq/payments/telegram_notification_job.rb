# frozen_string_literal: true

module Payments
  class TelegramNotificationJob
    include Sidekiq::Job
    sidekiq_options queue: 'default', tags: ['payments_telegram_notification']

    def perform(payment_id)
      payment = Payment.find(payment_id)

      notify_service = TelegramNotification::ProcessersService.new(payment)

      if payment.arbitration?
        notify_service.send_new_arbitration_notification_to_user(payment.processer.telegram_id)
        notify_service.send_new_arbitration_notification_to_user(payment.support.telegram_id)
      else
        notify_service.send_new_payment_notification_to_user(payment.processer.telegram_id)
      end
    end
  end
end

# frozen_string_literal: true

module Payments
  module Supports
    class NewArbitrationNotificationJob
      include Sidekiq::Job
      sidekiq_options queue: 'default', tags: ['payments_telegram_notification']

      def perform(payment_id)
        payment = Payment.find(payment_id)

        notify_service = TelegramNotification::PaymentsService.new(payment)

        notify_service.send_new_arbitration_notification_to_user(payment.support.telegram_id)
      end
    end
  end
end

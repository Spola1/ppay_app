# frozen_string_literal: true

module Payments
  class TelegramNotificationJob
    include Sidekiq::Job
    sidekiq_options queue: 'default', tags: ['payments_telegram_notification']

    def perform(national_currency_amount, card_number, national_currency, external_order_id,
                payment_status, payment_system, advertisement_card_number, type,
                status_changed_at, telegram, user_id)

      notify_service = TelegramNotificationService.new(national_currency_amount, card_number,
                                                       national_currency, external_order_id,
                                                       payment_status, payment_system,
                                                       advertisement_card_number, type,
                                                       status_changed_at, telegram)

      notify_service.send_notification_to_user(user_id)
    end
  end
end

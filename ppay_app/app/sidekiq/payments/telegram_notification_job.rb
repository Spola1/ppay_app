# frozen_string_literal: true

module Payments
  class TelegramNotificationJob
    include Sidekiq::Job
    sidekiq_options queue: 'default', tags: ['payments_telegram_notification']

    def perform(uuid, national_currency_amount, card_number, user_id)
      notify_service = TelegramNotificationService.new(uuid, national_currency_amount, card_number)
      notify_service.send_notification_to_user(user_id)
    end
  end
end

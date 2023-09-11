# frozen_string_literal: true

module BalanceRequests
  module Admins
    class NewBalanceRequestNotificationJob
      include Sidekiq::Job
      sidekiq_options queue: 'default', tags: ['balance_requests_telegram_notification']

      def perform(balance_request_id)
        balance_request = BalanceRequest.find(balance_request_id)

        notify_service = TelegramNotification::BalanceRequestsService.new(balance_request)

        telegram_ids =
          Admin.joins(:telegram_setting)
               .where.not(telegram_id: nil)
               .where(telegram_settings: { "balance_request_#{balance_request.requests_type}": true })
               .pluck(:telegram_id)
        notify_service.send_new_balance_request_to_users(telegram_ids)
      end
    end
  end
end

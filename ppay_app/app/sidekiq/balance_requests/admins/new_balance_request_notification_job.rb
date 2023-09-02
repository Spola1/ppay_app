# frozen_string_literal: true

module BalanceRequests
  module Admins
    class NewBalanceRequestNotificationJob
      include Sidekiq::Job
      sidekiq_options queue: 'default', tags: ['balance_requests_telegram_notification']

      def perform(balance_request_id)
        balance_request = BalanceRequest.find(balance_request_id)

        notify_service = TelegramNotification::BalanceRequestsService.new(balance_request)

        admin_ids_with_telegram = Admin.where.not(telegram_id: nil).pluck(:telegram_id)
        notify_service.send_new_balance_request_to_admins(admin_ids_with_telegram)
      end
    end
  end
end

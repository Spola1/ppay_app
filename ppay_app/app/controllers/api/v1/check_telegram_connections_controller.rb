# frozen_string_literal: true

module Api
  module V1
    class CheckTelegramConnectionsController < ApplicationController
      skip_before_action :verify_authenticity_token

      def check_connection_status
        data = JSON.parse(request.body.read)

        main_application_id = data['main_application_id']
        status = data['status']

        telegram_application = TelegramApplication.find(main_application_id)

        # Найти существующее соединение или создать новое
        telegram_connection = telegram_application.telegram_connections
                                                  .find_or_initialize_by(processer: telegram_application.processer)
        telegram_connection.update(status:)

        telegram_connection.touch
      end
    end
  end
end

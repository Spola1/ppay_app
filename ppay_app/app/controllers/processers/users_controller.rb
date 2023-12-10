# frozen_string_literal: true

module Processers
  class UsersController < Staff::BaseController
    def settings; end

    def check_telegram_connection_status
      @telegram_connections = current_user.telegram_connections.order(created_at: :asc)
    end

    private

    def settings_params
      params.require(:processer).permit(:telegram)
    end
  end
end

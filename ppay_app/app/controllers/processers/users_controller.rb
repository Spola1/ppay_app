# frozen_string_literal: true

module Processers
  class UsersController < Staff::BaseController
    def settings; end

    def settings_update
      @user = current_user
      @user.telegram_id = nil

      if @user.update(settings_params)
        redirect_back fallback_location: users_settings_path, notice: 'Профиль успешно обновлен'
      else
        redirect_back fallback_location: users_settings_path, status: :unprocessable_entity
      end
    end

    private

    def settings_params
      params.require(:processer).permit(:telegram, :receive_requests_enabled)
    end
  end
end

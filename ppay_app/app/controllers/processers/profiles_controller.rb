# frozen_string_literal: true

module Processers
  class ProfilesController < ApplicationController
    def edit
      @user = current_user
    end

    def update
      @user = current_user

      if params[:processer][:telegram].present?
        telegram = params[:processer][:telegram].gsub(/^@/, '')
        notify_service = TelegramNotification::GetUserIdService.new(telegram)
        telegram_id = notify_service.get_user_id(telegram)
      end

      if @user.update(user_params.merge(telegram_id: telegram_id)) && @user.telegram_id != nil
        redirect_to processers_profile_path, notice: 'Профиль успешно обновлен'
      else
        redirect_to processers_profile_path, notice: 'Профиль с таким никнеймом не найден'
      end
    end

    private

    def user_params
      params.require(:processer).permit(:telegram)
    end
  end
end

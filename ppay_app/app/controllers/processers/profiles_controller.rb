# frozen_string_literal: true

module Processers
  class ProfilesController < ApplicationController
    def edit
      @user = current_user
    end

    def update
      @user = current_user
      @user.telegram_id = nil

      if @user.update(user_params)
        redirect_to processers_profile_path, notice: 'Профиль успешно обновлен'
      else
        error_message = @user.errors.full_messages_for(:telegram).first || 'Профиль с таким никнеймом не найден'
        flash[:error] = error_message
        redirect_to processers_profile_path
      end
    end

    private

    def user_params
      params.require(:processer).permit(:telegram)
    end
  end
end

module Processers
  class ProfilesController < ApplicationController
    def edit
      @user = current_user
    end

    def update
      @user = current_user
      if @user.update(user_params)
        @user.update(user_params.merge(telegram_id: nil))
        redirect_to processers_profile_path, notice: 'Профиль успешно обновлен'
      else
        redirect_to processers_profile_path, notice: 'Неверный формат ссылки'
      end
    end

    private

    def user_params
      params.require(:processer).permit(:telegram)
    end
  end
end
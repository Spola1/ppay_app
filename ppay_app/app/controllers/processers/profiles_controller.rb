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
        redirect_to edit_processers_profile_path, notice: 'Профиль успешно обновлен'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def user_params
      params.require(:processer).permit(:telegram)
    end
  end
end

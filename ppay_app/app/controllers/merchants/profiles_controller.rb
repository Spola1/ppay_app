# frozen_string_literal: true

module Merchants
  class ProfilesController < ApplicationController
    def edit
      @user = current_user
    end

    def update
      @user = current_user
      @user.telegram_id = nil

      if @user.update(user_params)
        redirect_to edit_merchants_profile_path, notice: 'Профиль успешно обновлен'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def user_params
      params.require(:merchant).permit(:telegram)
    end
  end
end

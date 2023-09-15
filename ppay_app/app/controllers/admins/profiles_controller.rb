# frozen_string_literal: true

module Admins
  class ProfilesController < ApplicationController
    def edit
      @user = current_user
    end

    def update
      @user = current_user
      @user.telegram_id = nil

      if @user.update(user_params)
        redirect_to edit_admins_profile_path, notice: 'Профиль успешно обновлен'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def user_params
      params.require(:admin).permit(
        :telegram,
        telegram_setting_attributes: %i[balance_request_deposit
                                        balance_request_withdraw]
      )
    end
  end
end

# frozen_string_literal: true

module Merchants
  class UsersController < Staff::BaseController
    def settings
      nil
    end

    def settings_update
      current_user.update settings_params

      if current_user.save
        redirect_back fallback_location: users_settings_path
      else
        render :settings, alert: 'Can not update user profile.'
      end
    end

    private

    def settings_params
      params.require(:merchant).permit(:nickname)
    end
  end
end

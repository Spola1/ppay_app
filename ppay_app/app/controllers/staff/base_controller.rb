# frozen_string_literal: true

module Staff
  class BaseController < ApplicationController
    before_action :authenticate_user!

    def update
      current_user.update(user_params)
      redirect_back fallback_location: root_path
    end

    private

    def user_params
      params.require(:user).permit(:time_zone)
    end
  end
end

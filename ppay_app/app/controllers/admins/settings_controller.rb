# frozen_string_literal: true

module Admins
  class SettingsController < Staff::BaseController
    before_action :set_setting

    def edit; end

    def update
      if @setting.update(settings_params)
        redirect_to setting_path, notice: 'Настройки успешно обновлены'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_setting
      @setting = Setting.instance
    end

    def settings_params
      params.require(:setting).permit(:receive_requests_enabled, :commissions_version)
    end
  end
end

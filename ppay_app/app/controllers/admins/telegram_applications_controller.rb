# frozen_string_literal: true

module Admins
  class TelegramApplicationsController < ApplicationController
    before_action :set_processers, only: %i[new create]

    def show; end

    def index
      set_all_telegram_applications
    end

    def new
      @telegram_application = TelegramApplication.new
    end

    def create
      @telegram_application = TelegramApplication.new(telegram_application_params)

      if @telegram_application.save
        redirect_to telegram_applications_path, notice: 'Telegram Application успешно создан.'
      else
        render :new
      end
    end

    private

    def set_processers
      @processers = Processer.all
    end

    def set_all_telegram_applications
      @pagy, @telegram_applications = pagy(TelegramApplication.all)
      @telegram_applications = @telegram_applications.order(created_at: :desc).decorate
    end

    def telegram_application_params
      params.require(:telegram_application).permit(:api_id, :api_hash, :phone_number, :code, :session_name, 
                                                   :processer_id)
    end
  end
end

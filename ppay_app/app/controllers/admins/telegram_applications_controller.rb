# frozen_string_literal: true

module Admins
  class TelegramApplicationsController < ApplicationController
    before_action :set_processers, only: %i[new create edit]
    before_action :find_telegram_application, only: %i[edit show destroy update]

    def show; end

    def edit; end

    def destroy
      if @telegram_application.destroy
        redirect_to telegram_applications_path, notice: 'Приложение успешно удалено'
      else
        redirect_to telegram_applications_path, alert: 'Ошибка удаления приложения'
      end
    end

    def update
      @telegram_application.update(telegram_application_params)

      if @telegram_application.save
        send_data_to_microservice(@telegram_application)

        redirect_to telegram_applications_path, notice: 'Приложение успешно обновлено.'
      else
        render :edit
      end
    end

    def index
      set_all_telegram_applications
    end

    def new
      @telegram_application = TelegramApplication.new
    end

    def create
      @telegram_application = TelegramApplication.new(telegram_application_params)

      if @telegram_application.save
        send_data_to_microservice(@telegram_application)

        redirect_to telegram_applications_path, notice: 'Приложение успешно создано.'
      else
        render :new
      end
    end

    private

    def send_data_to_microservice(telegram_application)
      data_to_send = {
        api_id: telegram_application.api_id,
        api_hash: telegram_application.api_hash,
        session_name: telegram_application.session_name,
        phone_number: telegram_application.phone_number,
        code: telegram_application.code,
        main_application_id: telegram_application.id
      }

      send_request_to_microservice(data_to_send, 'create_telegram_application') if action_name == 'create'
      send_request_to_microservice(data_to_send, 'update_telegram_application') if action_name == 'update'
    end

    def send_request_to_microservice(data_to_send, endpoint)
      HTTParty.post(
        "http://localhost:3001/api/v1/#{endpoint}",
        body: data_to_send.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
    end

    def find_telegram_application
      @telegram_application = TelegramApplication.find(params[:id])
    end

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

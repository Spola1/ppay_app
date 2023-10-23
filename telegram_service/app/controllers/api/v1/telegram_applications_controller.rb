# frozen_string_literal: true

module Api
  module V1
    class TelegramApplicationsController < ApplicationController
      skip_before_action :verify_authenticity_token

      def create
        telegram_application = TelegramApplication.new(telegram_application_params)

        if telegram_application.save
          jid = TelegramApplicationJob.perform_async(telegram_application.id)
          telegram_application.update(jid: jid)

          render json: { status: 'success', message: 'Приложение успешно создано' }, status: :created
        else
          render json: { status: 'error', message: 'Ошибка создания приложения' }, status: :unprocessable_entity
        end
      end

      def update
        main_application_id = params[:main_application_id]
        telegram_application = TelegramApplication.find_by(main_application_id: main_application_id)

        if telegram_application
          if telegram_application.update(telegram_application_params)
            render json: { status: 'success', message: 'Приложение успешно обновлено' }
          else
            render json: { status: 'error', message: 'Ошибка обновления приложения' }, status: :unprocessable_entity
          end
        else
          render json: { status: 'error', message: 'Приложение не найдено' }, status: :not_found
        end
      end

      def check_job_status
        phone_number = params[:phone_number]
        telegram_application = TelegramApplication.where(phone_number: phone_number).last
        active_workers = Sidekiq::Workers.new

        if active_workers.find { |aw|
                                 aw[2]['payload']['tags'] == ['telegram_application'] &&
                                 aw[2]['payload']['jid'] == telegram_application.jid
                               }.present?

          render json: { status: 'Подключено' }, status: :ok
        else
          render json: { status: 'Не подключено' }, status: :ok
        end
      end

      private

      def telegram_application_params
        params.require(:telegram_application).permit(:api_id, :api_hash, :phone_number, :code, :session_name,
                                                     :main_application_id, bot_names: [])
      end
    end
  end
end

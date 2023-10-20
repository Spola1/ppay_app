# frozen_string_literal: true

module Admins
  class TelegramBotsController < ApplicationController
    before_action :find_telegram_bot, only: %i[edit show destroy update]

    def show; end

    def edit; end

    def destroy
      if @telegram_bot.destroy
        redirect_to telegram_bots_path, notice: 'Бот успешно удален'
      else
        redirect_to telegram_bots_path, alert: 'Ошибка удаления бота'
      end
    end

    def update
      @telegram_bot.update(telegram_bot_params)

      if @telegram_bot.save
        redirect_to telegram_bots_path, notice: 'Бот успешно обновлен'
      else
        render :edit
      end
    end

    def index
      set_all_telegram_bots
    end

    def new
      @telegram_bot = TelegramBot.new
    end

    def create
      @telegram_bot = TelegramBot.new(telegram_bot_params)

      if @telegram_bot.save
        redirect_to telegram_bots_path, notice: 'Бот успешно создан'
      else
        render :new
      end
    end

    private

    def find_telegram_bot
      @telegram_bot = TelegramBot.find(params[:id])
    end

    def set_all_telegram_bots
      @pagy, @telegram_bots = pagy(TelegramBot.all)
      @telegram_bots = @telegram_bots.order(created_at: :desc).decorate
    end

    def telegram_bot_params
      params.require(:telegram_bot).permit(:name, :chat_id)
    end
  end
end

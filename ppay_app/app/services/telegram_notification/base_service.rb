# frozen_string_literal: true

require 'net/http'
require 'json'
require 'telegram/bot'

module TelegramNotification
  class BaseService
    TELEGRAM_BOT_TOKEN = ENV.fetch('TELEGRAM_BOT_TOKEN', nil)
    API_URL = "https://api.telegram.org/bot#{TELEGRAM_BOT_TOKEN}/getUpdates".freeze

    def response
      response = Net::HTTP.get(URI(API_URL))
      json = JSON.parse(response)
      @updates = json['result']
    end

    def send_message_to_user(user_id, message)
      response

      ::Telegram::Bot::Client.run(TELEGRAM_BOT_TOKEN.to_s) do |bot|
        bot.api.send_message(chat_id: user_id, text: message)
      end
    end
  end
end

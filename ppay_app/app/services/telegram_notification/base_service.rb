# frozen_string_literal: true

require 'net/http'
require 'json'
require 'telegram/bot'

module TelegramNotification
  class BaseService
    TELEGRAM_BOT_TOKEN = ENV.fetch('TELEGRAM_BOT_TOKEN', nil)
    API_URL = "https://api.telegram.org/bot#{TELEGRAM_BOT_TOKEN}/getUpdates".freeze

    Telegram::Bot::Client.run(TELEGRAM_BOT_TOKEN) do |bot|
      bot.api.delete_webhook
    end

    def get_response
      response = Net::HTTP.get(URI(API_URL))
      json = JSON.parse(response)
      @updates = json['result']
    end
  end
end

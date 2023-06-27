# frozen_string_literal: true

module TelegramNotification
  class GetUserIdService < BaseService
    attr_reader :telegram

    def initialize(telegram)
      super()
      @telegram = telegram
    end

    def get_user_id(telegram)
      response
      user_id = nil

      @updates.each do |update|
        message = update['message']
        next unless message && message['chat'] && message['chat']['username'] == telegram

        user_id = message['chat']['id']
        break
      end

      user_id
    end
  end
end

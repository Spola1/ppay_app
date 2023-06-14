require 'telegram/bot'
require 'net/http'
require 'json'

class TelegramNotificationService
  TELEGRAM_BOT_TOKEN = ENV['TELEGRAM_BOT_TOKEN']
  API_URL = "https://api.telegram.org/bot#{TELEGRAM_BOT_TOKEN}/getUpdates"

  def initialize(uuid, national_currency_amount, card_number)
    @uuid = uuid
    @national_currency_amount = national_currency_amount
    @card_number = card_number
  end

  def get_response
    response = Net::HTTP.get(URI(API_URL))
    json = JSON.parse(response)
    @updates = json['result']
  end

  def get_user_id(username)
    get_response
    user_id = nil

    @updates.each do |update|
      message = update['message']
      next unless message && message['chat'] && message['chat']['username'] == username

      user_id = message['chat']['id']
      break
    end
    debugger

    user_id
  end

  def send_notification_to_user(user_id)
    message = "Уведомление о платеже:\n\n"
    message += "UUID: #{@uuid}\n"
    message += "Сумма: #{@national_currency_amount}\n"
    @card_number == nil ? message : message += "Номер карты оператора: #{@card_number}\n"

    send_message_to_user(user_id, message) unless user_id.nil?
  end

  private

  def send_message_to_user(user_id, message)
    get_response

    if @updates.last['my_chat_member'] == nil
      Telegram::Bot::Client.run("#{TELEGRAM_BOT_TOKEN}") do |bot|
        bot.api.send_message(chat_id: user_id, text: message)
      end
    end
  end
end
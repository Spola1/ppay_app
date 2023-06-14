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

  def get_user_id(username)
    response = Net::HTTP.get(URI(API_URL))
    json = JSON.parse(response)

    @updates = json['result']
    user_id = nil

    @updates.each do |update|
      message = update['message']
      next unless message && message['chat'] && message['chat']['username'] == username

      user_id = message['chat']['id']
      break
    end

    user_id
  end

  def send_notification_to_user(username)
    message = "Уведомление о платеже:\n\n"
    message += "UUID: #{@uuid}\n"
    message += "Сумма: #{@national_currency_amount}\n"
    @card_number == nil ? message : message += "Номер карты оператора: #{@card_number}\n"

    chat_id = get_user_id(username)
    send_message_to_user(chat_id, message) unless chat_id.nil?
    # unless chat_id.nil? защита на случай если пользователь
    # еще не написал ни одного сообщения/не отправил ни одной команды в бот
  end

  private

  def send_message_to_user(chat_id, message)
    if @updates.last['my_chat_member'] == nil # проверка на случай если пользователь заблокировал или отключил бота
      Telegram::Bot::Client.run("#{TELEGRAM_BOT_TOKEN}") do |bot|
        bot.api.send_message(chat_id: chat_id, text: message)
      end
    end
  end
end
# frozen_string_literal: true

require 'telegram/bot'
require 'net/http'
require 'json'
require 'date'

class TelegramNotificationService
  attr_reader :national_currency_amount, :card_number, :national_currency, :external_order_id, :payment_status,
              :payment_system, :advertisement_card_number, :type, :status_changed_at, :telegram

  TELEGRAM_BOT_TOKEN = ENV.fetch('TELEGRAM_BOT_TOKEN', nil)
  API_URL = "https://api.telegram.org/bot#{TELEGRAM_BOT_TOKEN}/getUpdates".freeze

  def initialize(national_currency_amount, card_number, national_currency, external_order_id, payment_status,
                 payment_system, advertisement_card_number, type, status_changed_at, telegram)
    @national_currency_amount = national_currency_amount
    @card_number = card_number
    @national_currency = national_currency
    @external_order_id = external_order_id
    @payment_status = payment_status
    @payment_system = payment_system
    @advertisement_card_number = advertisement_card_number
    @type = type
    @status_changed_at = status_changed_at
    @telegram = telegram
  end

  def get_response
    response = Net::HTTP.get(URI(API_URL))
    json = JSON.parse(response)
    @updates = json['result']
  end

  def get_user_id(telegram)
    get_response
    user_id = nil

    @updates.each do |update|
      message = update['message']
      next unless message && message['chat'] && message['chat']['username'] == telegram

      user_id = message['chat']['id']
      break
    end

    user_id
  end

  def send_notification_to_user(user_id)
    message = "Уведомление о платеже:\n\n"

    message += "Тип: #{I18n.t("activerecord.attributes.type.#{@type.downcase}")}\n"
    message += "Банк: #{@payment_system}\n"
    message += "Номер заказа: #{@external_order_id}\n"
    message += "Сумма: #{@national_currency_amount} #{@national_currency}\n"
    message += "Номер карты: #{@type == 'Deposit' ? @advertisement_card_number : @card_number}\n"
    message += "Статус: #{I18n.t("activerecord.attributes.payment/payment_status.#{@payment_status}")}\n"
    message += "Платёж будет отменен: #{time_of_payment_cancellation}"

    send_message_to_user(user_id, message) unless user_id.nil?
  end

  private

  def time_of_payment_cancellation
    datetime = DateTime.parse(@status_changed_at)
    new_datetime = datetime + Rational(20, 1440)

    formatted_datetime = new_datetime.strftime('%d-%m-%Y %H:%M:%S')
  end

  def send_message_to_user(user_id, message)
    get_response

    if @updates.last['my_chat_member'].nil?
      Telegram::Bot::Client.run(TELEGRAM_BOT_TOKEN.to_s) do |bot|
        bot.api.send_message(chat_id: user_id, text: message)
      end
    end
  end
end
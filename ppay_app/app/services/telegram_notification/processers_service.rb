# frozen_string_literal: true

require 'telegram/bot'
require 'date'

module TelegramNotification
  class ProcessersService < BaseService
    attr_reader :national_currency_amount, :card_number, :national_currency, :external_order_id, :payment_status,
                :payment_system, :advertisement_card_number, :type, :status_changed_at, :image

    def initialize(payment)
      @national_currency_amount = payment.national_currency_amount
      @card_number = payment.card_number
      @national_currency = payment.national_currency
      @external_order_id = payment.external_order_id
      @payment_status = payment.payment_status
      @payment_system = payment.payment_system
      @advertisement_card_number = payment.advertisement.card_number
      @type = payment.type
      @status_changed_at = payment.status_changed_at
    end

    def send_notification_to_user(user)
      message = "Уведомление о платеже:\n\n"

      message += "Тип: #{I18n.t("activerecord.attributes.type.#{@type.downcase}")}\n"
      message += "Банк: #{@payment_system}\n"
      message += "Номер заказа: #{@external_order_id}\n"
      message += "Сумма: #{@national_currency_amount} #{@national_currency}\n"
      message += "Номер карты: #{@type == 'Deposit' ? @advertisement_card_number : @card_number}\n"
      message += "Статус: #{I18n.t("activerecord.attributes.payment/payment_status.#{@payment_status}")}\n"
      message += "Платёж будет отменён: #{time_of_payment_cancellation}"

      send_message_to_user(user, message) unless user.nil?
    end

    private

    def time_of_payment_cancellation
      datetime = DateTime.parse(@status_changed_at.to_s)
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
end
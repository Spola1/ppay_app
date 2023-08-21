# frozen_string_literal: true

require 'telegram/bot'
require 'date'

module TelegramNotification
  class UsersService < BaseService
    attr_reader :payment, :national_currency_amount, :card_number, :national_currency, :external_order_id,
                :payment_status, :payment_system, :advertisement_card_number, :type, :status_changed_at, :uuid, :chat,
                :comment

    def initialize(payment)
      super()
      @national_currency_amount = payment.national_currency_amount
      @card_number = payment.card_number
      @national_currency = payment.national_currency
      @external_order_id = payment.external_order_id
      @payment_status = payment.payment_status
      @payment_system = payment.payment_system
      @advertisement_card_number = payment.advertisement.card_number
      @type = payment.type
      @status_changed_at = payment.status_changed_at
      @uuid = payment.uuid
      @payment = payment
      @chat = payment&.chats&.last
      @comment = payment&.comments&.last
    end

    def send_new_payment_notification_to_user(user)
      message = "Уведомление о платеже:\n\n"

      message += "Тип: #{I18n.t("activerecord.attributes.type.#{@type.downcase}")}\n"
      message += "Банк: #{@payment_system}\n"
      message += "Номер заказа: #{@external_order_id}\n"
      message += "Сумма: #{@national_currency_amount} #{@national_currency}\n"
      message += "Номер карты: #{@type == 'Deposit' ? @advertisement_card_number : @card_number}\n"
      message += "Статус: #{I18n.t("activerecord.attributes.payment/payment_status.#{@payment_status}")}\n"
      message += "Платёж будет отменён: #{time_of_payment_cancellation}\n"
      message += "Ссылка на платёж: \n"
      message += "#{PaymentUrlUtility.new(payment).url}\n"

      send_message_to_user(user, message) unless user.nil?
    end

    def send_new_arbitration_notification_to_user(user)
      message = "Арбитраж по платежу\n\n"

      message += "uuid: #{@uuid}\n"
      message += "Сумма: #{@national_currency_amount} #{@national_currency}\n"
      message += "Банк: #{@payment_system}\n"
      message += "Номер карты: #{@type == 'Deposit' ? @advertisement_card_number : @card_number}\n"
      message += "Ссылка на платёж: \n"
      message += "#{PaymentUrlUtility.new(payment).url}\n"

      send_message_to_user(user, message) unless user.nil?
    end

    def send_new_comment_notification_to_user(user)
      message = "Добавлен новый комментарий по арбитражу\n\n"

      message += "uuid: #{@uuid}\n"
      message += "Комментарий: #{@comment.text}\n"
      message += "Ссылка на платёж: \n"
      message += "#{PaymentUrlUtility.new(payment).url}\n"

      sender_user = @comment.user

      return unless sender_user && sender_user.telegram_id != user

      send_message_to_user(user, message)
    end

    def send_new_chat_notification_to_user(user)
      message = "Добавлено новое сообщение в чате по арбитражу\n\n"

      message += "uuid: #{@uuid}\n"
      message += "Сообщение: #{@chat.text}\n"
      message += "Ссылка на платёж: \n"
      message += "#{PaymentUrlUtility.new(payment).url}\n"

      sender_user = @chat.user

      return unless sender_user && sender_user.telegram_id != user

      send_message_to_user(user, message)
    end

    private

    def payment_type
      @type == 'Deposit' ? 'deposits' : 'withdrawals'
    end

    def time_of_payment_cancellation
      datetime = DateTime.parse(@status_changed_at.to_s)
      new_datetime = datetime + Rational(20, 1440)

      new_datetime.strftime('%d-%m-%Y %H:%M:%S')
    end

    def send_message_to_user(user_id, message)
      response

      Telegram::Bot::Client.run(TELEGRAM_BOT_TOKEN.to_s) do |bot|
        bot.api.send_message(chat_id: user_id, text: message)
      end
    end
  end
end

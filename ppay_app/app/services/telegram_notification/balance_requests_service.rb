# frozen_string_literal: true

require 'telegram/bot'
require 'date'

module TelegramNotification
  class BalanceRequestsService < BaseService
    attr_reader :balance_request, :request_type, :amount, :status, :crypto_address, :short_comment, :user

    def initialize(balance_request)
      super()
      @request_type = balance_request.requests_type
      @amount = balance_request.amount_minus_commission || balance_request.amount
      @status = balance_request.status
      @crypto_address = balance_request.crypto_address
      @short_comment = balance_request.short_comment
      @balance_request = balance_request
      @user = balance_request.user
    end

    def send_new_balance_request_to_users(telegram_ids)
      message = "Создан новый запрос баланса\n\n"
      message += "Дата создания: #{balance_request.created_at}\n"
      message += "Тип запроса: #{balance_request_type}\n"
      message += "Сумма: #{amount} #{user.balance.currency}\n"
      message += "#{balance_request_address}: #{@crypto_address}\n"
      message += "Пользователь: #{balance_request_user}\n"
      message += "Ссылка на запрос баланса: \n"
      message += "#{url}\n"

      telegram_ids.each do |telegram_id|
        send_message_to_user(telegram_id, message)
      end
    end

    private

    def balance_request_type
      @request_type == 'deposit' ? 'Депозит' : 'Вывод'
    end

    def balance_request_address
      user.balance.in_national_currency? ? 'Номер карты' : 'Криптоадрес'
    end

    def balance_request_user
      "#{user.type} #{user.nickname} (#{user.email})"
    end

    def url
      BalanceRequestUrlUtility.new(balance_request).url
    end
  end
end

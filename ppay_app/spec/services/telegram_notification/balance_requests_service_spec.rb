# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TelegramNotification::BalanceRequestsService do
  describe '#send_new_arbitration_notification_to_user' do
    let(:balance_request) { create(:balance_request, :deposit) }
    let(:user) { create(:user, :admin) }

    before do
      user.telegram_id = 123_123_123
    end

    it 'sends a notification message to the user' do
      service = described_class.new(balance_request)
      message = "Создан новый запрос баланса\n\n" \
                "Дата создания: #{balance_request.created_at}\n" \
                "Тип запроса: Депозит\n" \
                "Сумма: 1.0 USDT\n" \
                "Криптоадрес: MyString\n" \
                "Пользователь: Merchant AvangardBet (#{balance_request.user.email})\n" \
                "Ссылка на запрос баланса: \n" \
                "http://example.org/balance_requests/#{balance_request.id}\n"

      expect(service).to receive(:send_message_to_user)
        .with(user.telegram_id, message)

      service.send_new_balance_request_to_users([user.telegram_id])
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TelegramNotification::ProcessersService do
  describe '#send_notification_to_user' do
    context 'when payment type is Deposit' do
      let(:payment) { create(:payment, :deposit) }
      let(:ad) { create(:advertisement, :deposit) }

      before do
        payment.advertisement = ad
        payment.processer.telegram_id = 123_123_123
      end

      it 'sends a notification message to the user' do
        service = described_class.new(payment)
        message = "Уведомление о платеже:\n\n" \
                  "Тип: Депозит\n" \
                  "Банк: Sberbank\n" \
                  "Номер заказа: 1234\n" \
                  "Сумма: 100.0 RUB\n" \
                  "Номер карты: 1111111111111111\n" \
                  "Статус: #{I18n.t("activerecord.attributes.payment/payment_status.#{payment.payment_status}")}\n" \
                  "Платёж будет отменён: #{service.send(:time_of_payment_cancellation)}\n" \
                  "Ссылка на платёж: \n" \
                  "http://localhost:3000/payments/deposits/#{payment.uuid}\n"

        expect(service).to receive(:send_message_to_user)
          .with(payment.processer.telegram_id, message)

        service.send_notification_to_user(payment.processer.telegram_id)
      end
    end

    context 'when payment type is Withdrawal' do
      let(:payment) { create(:payment, :withdrawal) }
      let(:ad) { create(:advertisement, :withdrawal) }

      before do
        payment.advertisement = ad
        payment.processer.telegram_id = 123_123_123
        payment.card_number = '2222222222222222'
      end

      it 'sends a notification message to the user' do
        service = described_class.new(payment)
        message = "Уведомление о платеже:\n\n" \
                  "Тип: Вывод\n" \
                  "Банк: Sberbank\n" \
                  "Номер заказа: 1234\n" \
                  "Сумма: 100.0 RUB\n" \
                  "Номер карты: 2222222222222222\n" \
                  "Статус: #{I18n.t("activerecord.attributes.payment/payment_status.#{payment.payment_status}")}\n" \
                  "Платёж будет отменён: #{service.send(:time_of_payment_cancellation)}\n" \
                  "Ссылка на платёж: \n" \
                  "http://localhost:3000/payments/withdrawals/#{payment.uuid}\n"

        expect(service).to receive(:send_message_to_user)
          .with(payment.processer.telegram_id, message)

        service.send_notification_to_user(payment.processer.telegram_id)
      end
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TelegramNotification::PaymentsService do
  describe '#send_new_payment_notification_to_user' do
    context 'when payment type is Deposit' do
      let(:payment) { create(:payment, :deposit) }
      let(:ad) { create(:advertisement) }

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
                  "http://example.org/payments/deposits/#{payment.uuid}\n"

        expect(service).to receive(:send_message_to_user)
          .with(payment.processer.telegram_id, message)

        service.send_new_payment_notification_to_user(payment.processer.telegram_id)
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
                  "http://example.org/payments/withdrawals/#{payment.uuid}\n"

        expect(service).to receive(:send_message_to_user)
          .with(payment.processer.telegram_id, message)

        service.send_new_payment_notification_to_user(payment.processer.telegram_id)
      end
    end
  end

  describe '#send_new_arbitration_notification_to_user' do
    let(:payment) { create(:payment, :deposit, arbitration: true, advertisement: ad, support:) }
    let(:ad) { create(:advertisement) }
    let(:support) { create(:support) }
    let(:arbitration_resolution) { payment.arbitration_resolutions.create!(reason: 'incorrect_amount') }

    before do
      payment.processer.telegram_id = 123_123_123
      payment.support.telegram_id = 321_321_321
    end

    it 'sends a notification message to the user' do
      service = described_class.new(payment)
      message = "Арбитраж по платежу\n\n" \
                "uuid: #{payment.uuid}\n" \
                "Сумма: 100.0 RUB\n" \
                "Банк: Sberbank\n" \
                "Номер карты: 1111111111111111\n" \
                "Ссылка на платёж: \n" \
                "http://example.org/payments/deposits/#{payment.uuid}\n"

      expect(service).to receive(:send_message_to_user)
        .with(payment.processer.telegram_id, message)

      expect(service).to receive(:send_message_to_user)
        .with(payment.support.telegram_id, message)

      service.send_new_arbitration_notification_to_user(payment.processer.telegram_id)

      service.send_new_arbitration_notification_to_user(payment.support.telegram_id)
    end
  end

  describe '#send_new_chat_notification_to_user' do
    let(:payment) { create(:payment, :deposit, arbitration: true, advertisement: ad, support:) }
    let(:ad) { create(:advertisement) }
    let(:support) { create(:support, telegram_id: '321321321') }

    before do
      payment.support.chats.create(text: 'test', payment_id: payment.id)
      payment.processer.telegram_id = 123_123_123
      payment.merchant.telegram_id = 111_111_111
    end

    it 'sends a nsends a notification message to a user other than the author of the message' do
      service = described_class.new(payment)

      message = "Добавлено новое сообщение в чате по арбитражу\n\n" \
                "uuid: #{payment.uuid}\n" \
                "Сообщение: test\n" \
                "Ссылка на платёж: \n" \
                "http://example.org/payments/deposits/#{payment.uuid}\n"

      expect(service).to receive(:send_message_to_user)
        .with(payment.processer.telegram_id, message)

      expect(service).not_to receive(:send_message_to_user)
        .with(payment.support.telegram_id, message)

      expect(service).to receive(:send_message_to_user)
        .with(payment.merchant.telegram_id, message)

      service.send_new_chat_notification_to_user(payment.processer.telegram_id)
      service.send_new_chat_notification_to_user(payment.support.telegram_id)
      service.send_new_chat_notification_to_user(payment.merchant.telegram_id)
    end
  end

  describe '#send_new_comment_notification_to_user' do
    let(:payment) { create(:payment, :deposit, arbitration: true, advertisement: ad, support:) }
    let(:ad) { create(:advertisement) }
    let(:support) { create(:support, telegram_id: '321321321') }

    context 'when the support is the author of the comment' do
      before do
        payment.support.comments.create!(text: 'test', commentable_id: payment.id, commentable_type: 'Payment')
        payment.processer.telegram_id = 123_123_123
      end

      it 'sends a nsends a notification message to a user other than the author of the message' do
        service = described_class.new(payment)

        message = "Добавлен новый комментарий по арбитражу\n\n" \
                  "uuid: #{payment.uuid}\n" \
                  "Комментарий: test\n" \
                  "Ссылка на платёж: \n" \
                  "http://example.org/payments/deposits/#{payment.uuid}\n"

        expect(service).not_to receive(:send_message_to_user)
          .with(payment.support.telegram_id, message)

        service.send_new_comment_notification_to_user(payment.support.telegram_id)
      end
    end

    context 'when the support is not the author of the comment' do
      before do
        payment.processer.comments.create!(text: 'test', commentable_id: payment.id, commentable_type: 'Payment')
        payment.processer.telegram_id = 123_123_123
      end

      it 'sends a nsends a notification message to a user other than the author of the message' do
        service = described_class.new(payment)

        message = "Добавлен новый комментарий по арбитражу\n\n" \
                  "uuid: #{payment.uuid}\n" \
                  "Комментарий: test\n" \
                  "Ссылка на платёж: \n" \
                  "http://example.org/payments/deposits/#{payment.uuid}\n"

        expect(service).to receive(:send_message_to_user)
          .with(payment.support.telegram_id, message)

        service.send_new_comment_notification_to_user(payment.support.telegram_id)
      end
    end
  end
end

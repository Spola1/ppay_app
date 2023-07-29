require 'rails_helper'

RSpec.describe IncomingRequestService do
  let!(:processer) { create(:processer) }
  let!(:advertisement) { create(:advertisement, :deposit, processer:) }
  let!(:amount_mask) { create(:mask, :amount, sender: incoming_request.from) }
  let!(:card_mask) { create(:mask, :card_number, sender: incoming_request.from) }
  let!(:payment) { create(:payment, :deposit, :transferring, advertisement:) }
  let!(:incoming_request) { create(:incoming_request) }

  describe 'regexp' do
    it 'finds matching advertisement' do
      regexp = eval(card_mask.regexp)
      match = incoming_request.message.scan(regexp).first

      expect(match).not_to be_nil
      expect(match.first).to eq(advertisement.simbank_card_number)
    end

    it 'finds matching payment' do
      regexp = eval(amount_mask.regexp)
      match = incoming_request.message.scan(regexp).first

      expect(match).not_to be_nil
      expect(match.first.to_d).to eq(payment.national_currency_amount.to_d)
    end
  end

  describe '#process_request' do
    before do
      incoming_request.user = processer
      service = IncomingRequestService.new(incoming_request)
      service.process_request
    end

    context 'with valid values' do
      it 'returns correct find_matching_advertisement result' do
        expect(incoming_request.advertisement).to eq(advertisement)
        expect(incoming_request.card_mask).to eq(card_mask)
      end

      it 'returns correct find_matching_payment result and will automatically confirm the payment' do
        expect(incoming_request.payment).to eq(payment)
        expect(incoming_request.sum_mask).to eq(amount_mask)
        expect(incoming_request.payment.payment_status).to eq('completed')
      end

      it 'does not create any outstanding payments' do
        expect(NotFoundPayment.all.size).to eq(0)
      end

      it 'builds correct related models' do
        expect(incoming_request.advertisement).to eq(advertisement)
        expect(incoming_request.card_mask).to eq(card_mask)
        expect(incoming_request.payment).to eq(payment)
        expect(incoming_request.sum_mask).to eq(amount_mask)
      end

      it 'creates a comment for the payment with the correct message text' do
        last_comment = incoming_request.payment.comments.last

        expected_text = <<~TEXT.strip
          Schet *8412. Platezh s nomera 79529048819. Summa 100.00 RUB. Balans 94.87 RUB.

          request_type: SMS
          identifier: phone
          phone: 79231636742
          app: SMS Forwarder
          from: Raiffeisen

          симбанк подтвердил подтвердил платеж согласно этому сообщению
        TEXT

        expect(last_comment.text).to eq(expected_text)
      end

      it 'creates a success response' do
        service = IncomingRequestService.new(incoming_request)
        response = service.process_request
        expect(response).to eq({ status: 'success', message: 'Запрос успешно сохранен' })
      end
    end

    context 'with invalid advertisement' do
      let!(:advertisement) { create(:advertisement, :deposit, processer:, simbank_card_number: '1111') }

      it 'returns correct find_matching_advertisement result' do
        expect(incoming_request.advertisement).to eq(nil)
        expect(incoming_request.card_mask).to eq(card_mask)
      end

      it 'returns correct find_matching_payment result and will automatically confirm the payment' do
        expect(incoming_request.payment).to eq(nil)
        expect(incoming_request.sum_mask).to eq(nil)
      end

      it 'does not create any outstanding payments' do
        expect(NotFoundPayment.all.size).to eq(0)
      end

      it 'builds correct related models' do
        expect(incoming_request.advertisement).to eq(nil)
        expect(incoming_request.card_mask).to eq(card_mask)
        expect(incoming_request.payment).to eq(nil)
        expect(incoming_request.sum_mask).to eq(nil)
      end

      it 'creates a success response' do
        service = IncomingRequestService.new(incoming_request)
        response = service.process_request
        expect(response).to eq({ status: 'success', message: 'Запрос успешно сохранен' })
      end
    end

    context 'when advertisement simbank_auto_confirmation disabled' do
      let!(:advertisement) { create(:advertisement, :deposit, processer:, simbank_auto_confirmation: false) }

      it 'returns correct find_matching_advertisement result' do
        expect(incoming_request.advertisement).to eq(nil)
        expect(incoming_request.card_mask).to eq(card_mask)
      end

      it 'returns correct find_matching_payment result and will automatically confirm the payment' do
        expect(incoming_request.payment).to eq(nil)
        expect(incoming_request.sum_mask).to eq(nil)
      end

      it 'does not create any outstanding payments' do
        expect(NotFoundPayment.all.size).to eq(0)
      end

      it 'builds correct related models' do
        expect(incoming_request.advertisement).to eq(nil)
        expect(incoming_request.card_mask).to eq(card_mask)
        expect(incoming_request.payment).to eq(nil)
        expect(incoming_request.sum_mask).to eq(nil)
      end

      it 'creates a success response' do
        service = IncomingRequestService.new(incoming_request)
        response = service.process_request
        expect(response).to eq({ status: 'success', message: 'Запрос успешно сохранен' })
      end
    end

    context 'with valid advertisement but with a mismatched payment amount' do
      let!(:payment) { create(:payment, :deposit, :transferring, advertisement:, national_currency_amount: 99) }

      it 'returns correct find_matching_advertisement result' do
        expect(incoming_request.advertisement).to eq(advertisement)
        expect(incoming_request.card_mask).to eq(card_mask)
      end

      it 'returns correct find_matching_payment result and will automatically confirm the payment' do
        expect(incoming_request.payment).to eq(nil)
        expect(incoming_request.sum_mask).to eq(nil)
      end

      it 'does not create any outstanding payments' do
        expect(NotFoundPayment.all.size).to eq(1)
        expect(NotFoundPayment.last.payments).to eq([payment])
      end

      it 'builds correct related models' do
        expect(incoming_request.advertisement).to eq(advertisement)
        expect(incoming_request.card_mask).to eq(card_mask)
        expect(incoming_request.payment).to eq(nil)
        expect(incoming_request.sum_mask).to eq(nil)
      end

      it 'creates a success response' do
        service = IncomingRequestService.new(incoming_request)
        response = service.process_request
        expect(response).to eq({ status: 'success', message: 'Запрос успешно сохранен' })
      end
    end
  end
end

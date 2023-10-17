# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PaymentDecorator do
  let(:merchant) { create(:merchant) }
  let(:payment) do
    create(:payment, :processer_search, status_changed_at:, type:, advertisement:, form_customization:, merchant:)
  end
  let(:advertisement) { create :advertisement, card_number: '1111 1111 1111 1111' }
  let(:time_now) { FFaker::Time.datetime }
  let(:status_changed_at) { time_now - 10.minutes }
  let(:type) { 'Withdrawal' }
  let(:decorator) { payment.decorate }
  let(:form_customization) { nil }

  before do
    allow(Time).to receive(:now).and_return(time_now)
    payment.update(status_changed_at:)
  end

  describe '#card_owner_name' do
    let(:decorator) { payment.decorate }

    it 'returns the card owner name from advertisement' do
      expect(decorator.card_owner_name).to eq 'John Doe'
    end
  end

  describe '#sbp_phone_number' do
    let(:decorator) { payment.decorate }

    it 'returns the SBP phone number from advertisement' do
      expect(decorator.sbp_phone_number).to eq '+1234567890'
    end
  end

  describe '#formatted_card_number' do
    let(:payment) { create(:payment, :transferring, :deposit, advertisement:) }
    subject { payment.decorate }

    context 'when payment system is not ЕРИП БНБ' do
      it 'returns the original card number' do
        expect(subject.formatted_card_number).to eq('1111 1111 1111 1111 ')
      end
    end

    context 'when payment system is ЕРИП БНБ' do
      let(:payment) { create(:payment, :transferring, :deposit, payment_system: 'ЕРИП БНБ', advertisement:) }

      before do
        payment.advertisement.card_number = '1234/2345/23452345'
      end

      it 'returns the formatted card number' do
        expect(subject.formatted_card_number).to eq('1234/2345/23452345')
      end
    end
  end

  describe '#countdown_end_time' do
    context 'when differ_ftd_and_other_payments is true' do
      before do
        payment.merchant.update(differ_ftd_and_other_payments: true)
        payment.merchant.update(ftd_payment_default_summ: 100.0)
      end

      describe '#countdown_end_time' do
        context 'when cryptocurrency_amount equals ftd_payment_default_summ' do
          it 'returns the correct countdown end time' do
            expected_countdown_end_time = payment.status_changed_at + payment.merchant.ftd_payment_exec_time_in_sec
            expect(payment.decorate.countdown_end_time).to eq(expected_countdown_end_time)
          end
        end

        context 'when cryptocurrency_amount is not equal to ftd_payment_default_summ' do
          before do
            payment.merchant.update(ftd_payment_default_summ: 50)
          end

          it 'returns the correct countdown end time' do
            expected_countdown_end_time = payment.status_changed_at + payment.merchant.regular_payment_exec_time_in_sec
            expect(payment.decorate.countdown_end_time).to eq(expected_countdown_end_time)
          end
        end

        context 'when differ_ftd_and_other_payments is false' do
          before do
            payment.merchant.update(differ_ftd_and_other_payments: false)
          end

          it 'returns the correct countdown end time' do
            expected_countdown_end_time = payment.status_changed_at + payment.merchant.regular_payment_exec_time_in_sec
            expect(payment.decorate.countdown_end_time).to eq(expected_countdown_end_time)
          end
        end
      end
    end
  end

  describe '#countdown' do
    it 'should return countdown' do
      expect(payment.decorate.countdown).to eq('00:10:00')
    end

    context 'when the status was changed long ago' do
      let(:status_changed_at) { 1.day.ago }
      it 'should return 00:00:00' do
        expect(payment.decorate.countdown).to eq '00:00:00'
      end
    end
  end

  describe '#human_payment_status' do
    it 'Should return processer search if payment_status is Поиск оператора' do
      expect(payment.decorate.human_payment_status).to eq 'Поиск оператора'
    end
  end

  describe '#fiat_amount_with_currency' do
    it 'Should pass' do
      expect(payment.decorate.fiat_amount_with_currency).to eq '100.00 RUB'
    end
  end

  describe '#human_type' do
    context 'when payment.type == Deposit' do
      let(:type) { 'Deposit' }
      it 'If type == deposit then return ДЕПОЗИТ' do
        expect(payment.decorate.human_type).to eq 'ДЕПОЗИТ'
      end
    end

    it 'If type != deposit then return ВЫВОД' do
      expect(payment.decorate.human_type).to eq 'ВЫВОД'
    end
  end

  describe '#cryptocurrency_commission_amount' do
    subject { payment.decorate.cryptocurrency_commission_amount }

    let(:payment) { create(:payment, :with_transactions) }

    it 'calculates amount of all commissions' do
      is_expected.to eq(40)
    end
  end

  describe '#national_currency_commission_amount' do
    subject { payment.decorate.national_currency_commission_amount }

    let(:payment) { create(:payment, :with_transactions) }

    it 'calculates amount of all commissions and converts it to national currency' do
      is_expected.to eq(nil)
    end

    context 'when rate snapshot is associated' do
      let(:payment) { create(:payment, :with_transactions, rate_snapshot:) }
      let(:rate_snapshot) { create(:rate_snapshot, value: 10) }

      it 'calculates amount of all commissions and converts it to national currency' do
        is_expected.to eq(400)
      end
    end
  end

  describe 'form_customization' do
    let(:form_customization) { create(:form_customization, merchant:) }

    describe '#logo_image_tag' do
      context 'when merchant has a logo' do
        let(:logo_url) { form_customization.logo.url }
        let(:expected_logo_html) do
          %r{<div class="show-logo"><div class="logo_img"><img src=".*sample.jpeg" /></div></div>}
        end

        it 'returns the image tag with the logo' do
          expect(decorator.logo_image_tag).to match(expected_logo_html)
        end
      end

      context 'when merchant does not have a logo' do
        let(:form_customization) { create(:form_customization, merchant:, logo: nil) }

        it 'returns nil' do
          expect(decorator.logo_image_tag).to be_nil
        end
      end
    end

    describe '#background_color_style' do
      context 'when merchant has a background color' do
        it 'returns the background color style' do
          expect(decorator.background_color_style).to eq('background-color: pink;')
        end
      end

      context 'when merchant does not have a background color' do
        let(:form_customization) { create(:form_customization, merchant:, background_color: nil) }

        it 'returns nil' do
          expect(decorator.background_color_style).to be_nil
        end
      end
    end

    describe '#button_color_style' do
      context 'when merchant has a button color' do
        it 'returns the button color style' do
          expect(decorator.button_color_style).to eq('background-color: red;')
        end
      end

      context 'when merchant does not have a button color' do
        let(:form_customization) { create(:form_customization, merchant:, button_color: nil) }

        it 'returns nil' do
          expect(decorator.button_color_style).to be_nil
        end
      end
    end
  end
end

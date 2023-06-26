# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PaymentDecorator do
  let(:payment) { create(:payment, :processer_search, status_changed_at:, type:) }
  let(:time_now) { FFaker::Time.datetime }
  let(:status_changed_at) { time_now - 10.minutes }
  let(:type) { 'Withdrawal' }
  let(:decorator) { payment.decorate }
  let(:form_customization) { create(:form_customization, merchant: payment.merchant) }

  before do
    allow(Time).to receive(:now).and_return(time_now)
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

  describe '#countdown_end_time' do
    it 'Should return status_changed_at + 20' do
      expect(payment.decorate.countdown_end_time).to eq(payment.status_changed_at + 20.minutes)
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
      it 'If type == deposit then return Депозит' do
        expect(payment.decorate.human_type).to eq 'Депозит'
      end
    end

    it 'If type != deposit then return Вывод' do
      expect(payment.decorate.human_type).to eq 'Вывод'
    end
  end

  describe '#type_icon' do
    context 'when payment.type == Deposit' do
      let(:type) { 'Deposit' }
      it 'If type == deposit then return arrow-up' do
        expect(payment.decorate.type_icon).to eq 'arrow-up'
      end
    end

    it 'If type == deposit then return arrow-down' do
      expect(payment.decorate.type_icon).to eq 'arrow-down'
    end
  end

  describe '#cryptocurrency_commission_amount' do
    subject { payment.decorate.cryptocurrency_commission_amount }

    let(:payment) { create(:payment, :with_transactions) }

    it 'calculates amount of all commissions' do
      is_expected.to eq(20)
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
        is_expected.to eq(200)
      end
    end
  end

  describe '#logo_image_tag' do
    context 'when merchant has a logo' do
      before do
        allow(form_customization.logo).to receive(:present?).and_return(true)
        allow(decorator)
          .to receive_message_chain('h.content_tag')
          .and_return("<div class='show-logo'><div class='logo_img'><img src='logo_url' /></div></div>")
      end

      it 'returns the image tag with the logo' do
        expect(decorator.logo_image_tag)
          .to eq("<div class='show-logo'><div class='logo_img'><img src='logo_url' /></div></div>")
      end
    end

    context 'when merchant does not have a logo' do
      before do
        allow(form_customization.logo).to receive(:present?).and_return(false)
      end

      it 'returns nil' do
        expect(decorator.logo_image_tag).to be_nil
      end
    end
  end

  describe '#background_color_style' do
    context 'when merchant has a background color' do
      before do
        allow(form_customization).to receive(:background_color).and_return('red')
      end

      it 'returns the background color style' do
        expect(decorator.background_color_style).to eq('background-color: red;')
      end
    end

    context 'when merchant does not have a background color' do
      before do
        allow(form_customization).to receive(:background_color).and_return(nil)
      end

      it 'returns nil' do
        expect(decorator.background_color_style).to be_nil
      end
    end
  end

  describe '#button_color_style' do
    context 'when merchant has a button color' do
      before do
        allow(form_customization).to receive(:button_color).and_return('blue')
      end

      it 'returns the button color style' do
        expect(decorator.button_color_style).to eq('background-color: blue;')
      end
    end

    context 'when merchant does not have a button color' do
      before do
        allow(form_customization).to receive(:button_color).and_return(nil)
      end

      it 'returns nil' do
        expect(decorator.button_color_style).to be_nil
      end
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PaymentDecorator do
  let(:payment) { create(:payment, :processer_search, status_changed_at:, type:) }
  let(:time_now) { FFaker::Time.datetime }
  let(:status_changed_at) { time_now - 10.minutes }
  let(:type) { 'Withdrawal' }

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
end

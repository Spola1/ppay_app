# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PaymentDecorator do
  let(:payment) { create :payment }
  describe '#countdown' do
    it 'Should return 00:00:00' do
      payment.status_changed_at = Time.new(2022, 1, 1)
      expect(payment.decorate.countdown).to eq '00:00:00'
    end

    it 'Should return correct Time' do
      payment.status_changed_at = Time.now
      expect(payment.decorate.countdown.to_i).to be_within(1.second).of Time.now.strftime('%H:%M:%S').to_i
    end
  end

  describe '#countdown_end_time' do
    it 'Should return status_changed_at + 20' do
      payment.status_changed_at = Time.now
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
      expect(payment.decorate.fiat_amount_with_currency).to eq "#{'%.2f' % payment.national_currency_amount} #{payment.national_currency}"
    end
  end

  describe '#human_type' do
    it 'If type == deposit then return Депозит' do
      payment.type = 'Deposit'
      expect(payment.decorate.human_type).to eq 'Депозит'
    end

    it 'If type != deposit then return Вывод' do
      payment.type = ''
      expect(payment.decorate.human_type).to eq 'Вывод'
    end
  end

  describe '#type_icon' do
    it 'If type == deposit then return arrow-up' do
      payment.type = 'Deposit'
      expect(payment.decorate.type_icon).to eq 'arrow-up'
    end

    it 'If type == deposit then return arrow-down' do
      payment.type = ''
      expect(payment.decorate.type_icon).to eq 'arrow-down'
    end
  end
end

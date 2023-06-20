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

  describe '#countdown_end_time' do
    context 'when differ_ftd_and_other_payments is true' do
      before do
        payment.merchant.update(differ_ftd_and_other_payments: true)
        payment.merchant.update(ftd_payment_default_summ: 1)
      end

      context 'when cryptocurrency_amount equals ftd_payment_default_summ' do
        it 'returns the correct countdown end time' do
          expected_countdown_end_time = status_changed_at + payment.merchant.ftd_payment_exec_time_in_sec.seconds
          expect(payment.decorate.countdown_end_time).to eq(expected_countdown_end_time)
        end
      end

      context 'when cryptocurrency_amount is not equal to ftd_payment_default_summ' do
        before do
          payment.merchant.update(ftd_payment_default_summ: 50)
        end

        it 'returns the correct countdown end time' do
          expected_countdown_end_time = status_changed_at + payment.merchant.regular_payment_exec_time_in_sec.seconds
          expect(payment.decorate.countdown_end_time).to eq(expected_countdown_end_time)
        end
      end
    end

    context 'when differ_ftd_and_other_payments is false' do
      before do
        payment.merchant.update(differ_ftd_and_other_payments: false)
      end

      it 'returns the correct countdown end time' do
        expected_countdown_end_time = status_changed_at + payment.merchant.regular_payment_exec_time_in_sec.seconds
        expect(payment.decorate.countdown_end_time).to eq(expected_countdown_end_time)
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
end

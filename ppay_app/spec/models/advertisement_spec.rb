# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Advertisement, type: :model do
  it { is_expected.to have_many(:payments) }
  it { is_expected.to have_many(:deposits) }
  it { is_expected.to have_many(:withdrawals) }
  it { is_expected.to belong_to(:processer) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:direction) }
    it { is_expected.to validate_presence_of(:national_currency) }
    it { is_expected.to validate_presence_of(:cryptocurrency) }
    it { is_expected.to validate_presence_of(:payment_system) }
  end

  describe 'card_number validations' do
    subject { build :advertisement, direction:, card_number: }

    context 'for deposits' do
      let(:direction) { 'Deposit' }

      context 'valid number' do
        let(:card_number) { '1234 1234 1234 1234' }

        it { is_expected.to be_valid }
      end

      [
        nil,
        '123'
      ].each do |number|
        context 'invalid number' do
          let(:card_number) { number }

          it { is_expected.to_not be_valid }
        end
      end
    end

    context 'for withdrawals' do
      let(:direction) { 'Withdrawal' }

      context 'not required' do
        let(:card_number) { nil }

        it { is_expected.to be_valid }
      end
    end
  end

  describe 'scopes' do
    describe 'active scope' do
      let!(:advertisement1) { create(:advertisement, status: true) }
      let!(:advertisement2) { create(:advertisement, status: false) }

      it 'returns active advertisements' do
        expect(Advertisement.active).to include(advertisement1)
      end

      it 'does not return inactive advertisements' do
        expect(Advertisement.active).not_to include(advertisement2)
      end
    end

    describe '.by_payment_system' do
      let!(:advertisement) { create(:advertisement, payment_system: 'AlfaBank') }

      it 'returns advertisements by payment system' do
        expect(Advertisement.by_payment_system('AlfaBank')).to include(advertisement)
      end

      it 'does not return advertisements by payment system' do
        expect(Advertisement.by_payment_system('Tinkoff')).not_to include(advertisement)
      end
    end

    describe '.by_amount' do
      let(:max_summ) { 10_000 }
      let(:min_summ) { 10 }
      let!(:advertisement) { create(:advertisement, min_summ:, max_summ:) }

      it 'returns advertisements by amount' do
        expect(Advertisement.by_amount(max_summ)).to include(advertisement)
        expect(Advertisement.by_amount(min_summ)).to include(advertisement)
      end

      it 'does not return advertisements by amount < min_summ' do
        expect(Advertisement.by_amount(min_summ - 1)).not_to include(advertisement)
      end

      it 'does not return advertisements by amount > max_summ' do
        expect(Advertisement.by_amount(max_summ + 1)).not_to include(advertisement)
      end
    end

    describe '.by_processer_balance' do
      let!(:advertisement) { create(:advertisement, processer:) }
      let!(:processer) { create(:processer) }

      it 'returns advertisements by amount == processer_balance' do
        expect(Advertisement.by_processer_balance(processer.balance.amount)).to include(advertisement)
      end

      it 'returns advertisements by amount < processer_balance' do
        expect(Advertisement.by_processer_balance(processer.balance.amount - 1)).to include(advertisement)
      end

      it 'does not return advertisements by amount > processer_balance' do
        expect(Advertisement.by_processer_balance(processer.balance.amount + 1)).not_to include(advertisement)
      end
    end

    describe '.by_direction' do
      subject { Advertisement.by_direction(direction) }

      let!(:deposit_ad) { create(:advertisement) }
      let!(:withdrawal_ad) { create(:advertisement, :withdrawal) }

      context 'on Deposit' do
        let(:direction) { 'Deposit' }

        it 'returns deposit advertisements' do
          is_expected.to include(deposit_ad)
        end

        it 'does not return withdrawal advertisements' do
          is_expected.not_to include(withdrawal_ad)
        end
      end

      context 'on Withdrawal' do
        let(:direction) { 'Withdrawal' }

        it 'returns withdrawal advertisements' do
          is_expected.to include(withdrawal_ad)
        end

        it 'does not return deposit advertisements' do
          is_expected.not_to include(deposit_ad)
        end
      end
    end

    describe 'filter scope' do
      let!(:advertisement1) do
        create(:advertisement, status: true, card_number: '1111 1111 1111 1111', simbank_card_number: '1234',
                               card_owner_name: 'VASYA')
      end
      let!(:advertisement2) do
        create(:advertisement, status: false, card_number: '1234 1234 1234 1234', simbank_card_number: '7777',
                               card_owner_name: 'MIHAIL')
      end
      let!(:advertisement3) do
        create(:advertisement, status: true, card_number: '1111 1111 1111 1112', simbank_card_number: '9394',
                               card_owner_name: 'ALEXEI')
      end
      let!(:advertisement4) do
        create(:advertisement, status: false, card_number: '4321 4321 4321 4321', simbank_card_number: '8154',
                               card_owner_name: 'KIRILL')
      end

      describe '.filter_by_status' do
        subject(:advertisements) { Advertisement.filter_by_status('Aктивно') }
        let(:correct_result) { [advertisement1, advertisement3] }
        it { expect(advertisements.to_a).to eq(correct_result) }
      end

      describe '.filter_by_card_number' do
        subject(:advertisements) { Advertisement.filter_by_card_number('1111') }
        let(:correct_result) { [advertisement1, advertisement3] }
        it { expect(advertisements.to_a).to eq(correct_result) }
      end

      describe '.filter_by_card_owner_name' do
        subject(:advertisements) { Advertisement.filter_by_card_owner_name('mi') }
        let(:correct_result) { [advertisement2] }
        it { expect(advertisements.to_a).to eq(correct_result) }
      end

      describe '.filter_by_simbank_card_number' do
        subject(:advertisements) { Advertisement.filter_by_simbank_card_number('1') }
        let(:correct_result) { [advertisement1, advertisement4] }
        it { expect(advertisements.to_a).to eq(correct_result) }
      end
    end

    # def advertisement_with_payments(payments_count: 3)
    #   FactoryBot.create(:advertisement, status: false,
    #                                     block_reason: :exceed_daily_usdt_card_limit,
    #                                     card_number: '45678') do |advertisement|
    #     FactoryBot.create(:processer, daily_usdt_card_limit: 300, advertisements: [advertisement])
    #     FactoryBot.create_list(:payment, payments_count, payment_status: 'completed', advertisement:)
    #   end
    # end

    def processer_with_payments(payments_count: 3)
      FactoryBot.create(:processer, daily_usdt_card_limit: 100) do |processer|
        FactoryBot.create(:advertisement, status: false,
                                          block_reason: :exceed_daily_usdt_card_limit,
                                          processer:) do |advertisement|
          FactoryBot.create_list(:payment, payments_count, payment_status: 'completed', advertisement:)
        end
      end
    end

    describe '.for_enable_status' do
      subject(:advertisements) { Advertisement.for_enable_status }
      let!(:processer_with_payments1) { processer_with_payments }
      it {
        expect(advertisements).to eq(processer_with_payments1.advertisements)
      }
    end
  end
end

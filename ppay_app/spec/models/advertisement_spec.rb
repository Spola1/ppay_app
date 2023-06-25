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
      let!(:advertisement1) { create(:advertisement, :deposit, status: true) }
      let!(:advertisement2) { create(:advertisement, :deposit, status: false) }

      it 'returns active advertisements' do
        expect(Advertisement.active).to include(advertisement1)
      end

      it 'does not return inactive advertisements' do
        expect(Advertisement.active).not_to include(advertisement2)
      end
    end

    describe '.by_payment_system' do
      let!(:advertisement) { create(:advertisement, :deposit, payment_system: 'AlfaBank') }

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
      let!(:advertisement) { create(:advertisement, :deposit, min_summ:, max_summ:) }

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
      let!(:advertisement) { create(:advertisement, :deposit, processer:) }
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

      let!(:deposit_ad) { create(:advertisement, :deposit) }
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

    describe '.for_payment' do
      subject { Advertisement.for_payment(payment) }

      let!(:advertisement_1) { create(:advertisement, :deposit, payment_system: 'Sberbank') }
      let!(:advertisement_2) { create(:advertisement, :deposit, payment_system: 'Sberbank') }
      let!(:advertisement_3) { create(:advertisement, :deposit, payment_system: 'Sberbank') }

      let(:payment) { create(:payment, :deposit, :processer_search) }

      before do
        # advertisement 1 - много активный платежей в процессе с такой же суммой
        create_list(:payment, 10, :transferring, advertisement: advertisement_1)

        # advertisement 2 - много активных платежей с разными суммами, в том числе с такой же
        create_list(:payment, 6, :transferring, advertisement: advertisement_2)
        create_list(:payment, 6, :transferring, advertisement: advertisement_2, national_currency_amount: 200)

        # advertisement 3 - много неактивных завершенных платежей с такой же суммой, но мало активных
        create_list(:payment, 20, :completed, advertisement: advertisement_3)
        create_list(:payment, 5, :transferring, advertisement: advertisement_3)
      end

      it {
        debugger
        is_expected.to eq([advertisement_3, advertisement_2, advertisement_1])
      }
    end
  end
end

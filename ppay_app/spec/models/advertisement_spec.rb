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
    it 'validates the length of card_number == 16' do
      advertisement = build(:advertisement, direction: 'Deposit', card_number: '1234567812345678')
      expect(advertisement.save).to be_truthy
      expect(advertisement).to be_valid
    end

    it 'does not validates the length of card_number.length < 16' do
      advertisement = build(:advertisement, direction: 'Deposit', card_number: '123456781234567')
      expect(advertisement.save).not_to be_truthy
      expect(advertisement).not_to be_valid
    end

    it 'does not validates the length of card_number.length > 16' do
      advertisement = build(:advertisement, direction: 'Deposit', card_number: '12345678123456789')
      expect(advertisement.save).not_to be_truthy
      expect(advertisement).not_to be_valid
    end
  end

  describe 'scopes' do
    describe 'active scope' do
      let!(:advertisement1) { create(:advertisement, :deposit, status: true) }
      let!(:advertisement2) { create(:advertisement, :deposit, status: false) }

      it 'returns active advertisements' do
        expect(Advertisement.active).to include(advertisement1)
      end

      it 'does not returns active advertisements' do
        expect(Advertisement.active).not_to include(advertisement2)
      end
    end

    describe '.by_payment_system' do
      let!(:advertisement1) { create(:advertisement, :deposit, :payment_system) }

      it 'returns advertisements by payment system' do
        expect(Advertisement.by_payment_system('AlfaBank')).to include(advertisement1)
      end

      it 'does not returns advertisements by payment system' do
        expect(Advertisement.by_payment_system('Tinkoff')).not_to include(advertisement1)
      end
    end

    describe '.by_amount' do
      let(:max_summ) { 10_000 }
      let(:min_summ) { 10 }
      let!(:advertisement1) { create(:advertisement, :deposit, :min_summ, :max_summ) }
      it 'returns advertisements by amount' do
        expect(Advertisement.by_amount(max_summ - 1)).to include(advertisement1)
        expect(Advertisement.by_amount(min_summ + 1)).to include(advertisement1)
      end

      it 'does not returns advertisements by amount < min_summ' do
        expect(Advertisement.by_amount(min_summ - 1)).not_to include(advertisement1)
      end

      it 'does not returns advertisements by amount > max_summ' do
        expect(Advertisement.by_amount(max_summ + 1)).not_to include(advertisement1)
      end
    end

    describe '.by_processer_balance' do
      let!(:advertisement1) { create(:advertisement, :deposit) }
      let!(:processer1) { create(:processer) }
      it 'returns advertisements by amount == processer_balance' do
        expect(Advertisement.by_processer_balance(processer1.balance.amount)).to include(advertisement1)
      end

      it 'returns advertisements by amount < processer_balance' do
        expect(Advertisement.by_processer_balance(processer1.balance.amount - 1)).to include(advertisement1)
      end

      it 'does not returns advertisements by amount > processer_balance' do
        expect(Advertisement.by_processer_balance(processer1.balance.amount + 1)).not_to include(advertisement1)
      end
    end

    describe '.by_direction' do
      let!(:advertisement1) { create(:advertisement, :deposit) }
      let!(:advertisement2) { create(:advertisement, :withdrawal) }
      it 'returns advertisements by deposit direction' do
        expect(Advertisement.by_direction('Deposit')).to include(advertisement1)
      end

      it 'does not returns advertisements by deposit direction' do
        expect(Advertisement.by_direction('Deposit')).not_to include(advertisement2)
      end

      it 'returns advertisements by withdrawal direction' do
        expect(Advertisement.by_direction('Withdrawal')).to include(advertisement2)
      end

      it 'does not returns advertisements by withdrawal direction' do
        expect(Advertisement.by_direction('Withdrawal')).not_to include(advertisement1)
      end
    end
  end
end

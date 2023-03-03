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
    # it { is_expected.to validate_presence_of(:card_number) }
  end

  describe 'scopes' do
    let(:advertisement1) { create(:advertisement, :deposit) }
    let(:advertisement2) { create(:advertisement, :withdrawal) }

    describe '.active' do
      let(:advertisement1) { create(:advertisement, :deposit, status: true) }

      it 'returns active advertisements' do
        expect(Advertisement.active).to match_array [advertisement1]
      end

      it 'does not returns active advertisements' do
        create(:advertisement, :deposit, status: false)
        expect(Advertisement.active).to be_empty
      end
    end

    describe '.by_payment_system' do
      it 'returns advertisements by payment system' do
        expect(Advertisement.by_payment_system('AlfaBank')).to match_array [advertisement1]
      end

      it 'does not returns advertisements by payment system' do
        create(:advertisement, :deposit)
        expect(Advertisement.by_payment_system('Tinkoff')).to be_empty
      end
    end

    describe '.by_amount' do
      it 'returns advertisements by amount' do
        expect(Advertisement.by_amount(1000)).to match_array [advertisement1]
      end

      it 'does not returns advertisements by amount < min_summ' do
        create(:advertisement, :deposit)
        expect(Advertisement.by_amount(9)).to be_empty
      end

      it 'does not returns advertisements by amount > max_summ' do
        create(:advertisement, :deposit)
        expect(Advertisement.by_amount(10_001)).to be_empty
      end
    end

    describe '.by_processer_balance' do
      it 'returns advertisements by amount' do
        expect(Advertisement.by_processer_balance(1000)).to match_array [advertisement1]
      end

      it 'does not returns advertisements by amount > processer_balance' do
        create(:advertisement, :deposit)
        expect(Advertisement.by_processer_balance(1001)).to be_empty
      end
    end

    describe '.by_direction' do
      it 'returns advertisements by deposit direction' do
        expect(Advertisement.by_direction('Deposit')).to match_array [advertisement1]
      end

      it 'does not returns advertisements by deposit direction' do
        create(:advertisement, :withdrawal)
        expect(Advertisement.by_direction('Deposit')).to be_empty
      end

      it 'returns advertisements by withdrawal direction' do
        expect(Advertisement.by_direction('Withdrawal')).to match_array [advertisement2]
      end

      it 'does not returns advertisements by withdrawal direction' do
        create(:advertisement, :deposit)
        expect(Advertisement.by_direction('Withdrawal')).to be_empty
      end
    end
  end
end

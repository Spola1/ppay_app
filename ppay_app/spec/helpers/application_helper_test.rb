# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  let(:user) { create :merchant, :with_all_kind_of_payments }

  describe 'hotlist_payments' do
    subject { helper.hotlist_payments(user) }

    it 'returns decorated deposits' do
      expect(subject.count).to eq 2
      expect([DepositDecorator, WithdrawalDecorator].include?(subject.first.class)).to be_truthy
    end
  end

  describe '.deposit_hotlist_advertisements' do
    let!(:processer) { create(:processer) }
    let!(:active_advertisement) { create(:advertisement, :deposit, processer: processer, status: true) }
    let!(:inactive_advertisement) { create(:advertisement, :deposit, processer: processer, status: false) }

    context 'advertisements without payments' do
      it 'returns advertisements with active status' do
        result = deposit_hotlist_advertisements(processer)

        expect(result).to include(active_advertisement)
        expect(result).not_to include(inactive_advertisement)
      end
    end

    context 'advertisements with active payment in inactive advertisement' do
      let!(:payment) { create(:payment, :deposit, :transferring, advertisement: inactive_advertisement) }

      it 'returns advertisements with active and inactive statuses' do
        result = deposit_hotlist_advertisements(processer)

        expect(result).to eq([active_advertisement, inactive_advertisement])
      end
    end
  end

  describe '.withdrawal_hotlist_advertisements' do
    let!(:processer) { create(:processer) }
    let!(:active_advertisement) { create(:advertisement, :withdrawal, processer: processer, status: true) }
    let!(:inactive_advertisement) { create(:advertisement, :withdrawal, processer: processer, status: false) }

    context 'advertisements without payments' do
      it 'returns advertisements with active status' do
        result = withdrawal_hotlist_advertisements(processer)

        expect(result).to include(active_advertisement)
        expect(result).not_to include(inactive_advertisement)
      end
    end

    context 'advertisements with active payment in inactive advertisement' do
      let!(:payment) { create(:payment, :withdrawal, :transferring, advertisement: inactive_advertisement) }

      it 'returns advertisements with active and inactive statuses' do
        result = withdrawal_hotlist_advertisements(processer)

        expect(result).to eq([active_advertisement, inactive_advertisement])
      end
    end
  end
end

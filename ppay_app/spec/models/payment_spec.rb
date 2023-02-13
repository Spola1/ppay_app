# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Payment, type: :model do
  it { is_expected.to have_many(:transactions) }

  it { is_expected.to belong_to(:rate_snapshot).optional(true) }
  it { is_expected.to belong_to(:advertisement).optional(true) }

  context 'validation' do
    let(:payment1) { create :payment }
    let(:payment2) { create :payment, :cancelled }
    describe 'before_save' do
      it 'Arbitration should be true if status is not cancelled or completed and not changed' do
        expect(payment1.arbitration).to eq true
      end

      it 'Arbitration should be true if status is not cancelled or completed and changed' do
        payment1.payment_status = :transferring
        expect(payment1.arbitration).to eq true
      end

      it 'Arbitration should be true if status is completed or cancelled and not changed' do
        expect(payment1.arbitration).to eq true
      end

      it 'Arbitration should be false if status is completed or cancelled and changed' do
        payment2.payment_status = :completed
        expect(payment2.arbitration).to eq false
      end
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Payment, type: :model do
  it { is_expected.to have_many(:transactions) }

  it { is_expected.to belong_to(:rate_snapshot).optional(true) }
  it { is_expected.to belong_to(:advertisement).optional(true) }

  describe '#ensure_unique_amount' do
    let!(:payment_1) { create(:payment, :confirming, :deposit) }
    let!(:payment_2) { create(:payment, :transferring, :withdrawal, national_currency_amount: 101) }
    let!(:payment_3) { create(:payment, :transferring, :withdrawal, national_currency_amount: 100.49) }

    context 'when merchant unique_amount_none' do
      it 'does not change national_currency_amount' do
        payment = build(:payment, :deposit)

        expect { payment.save }.not_to change(payment, :national_currency_amount)
      end
    end

    context 'when merchant unique_amount_integer' do
      it 'increases national_currency_amount by 1' do
        payment = build(:payment, :deposit)
        payment.merchant.unique_amount = 'integer'

        expect { payment.save }.to change(payment, :national_currency_amount).from(100).to(102)
      end
    end

    context 'when merchant unique_amount_decimal' do
      it 'increases national_currency_amount by difference between rounded number and national_currency_amount' do
        payment = build(:payment, :deposit, national_currency_amount: 100.49)
        payment.merchant.unique_amount = 'decimal'

        expect { payment.save }.to change(payment, :national_currency_amount).from(100.49).to(102.0)
      end
    end
  end

  describe ':check event' do
    context 'when image is present and merchant check is required' do
      let(:payment) { create(:payment, :deposit, :transferring) }
      let(:params) { { image: fixture_file_upload('spec/fixtures/test_files/sample.jpeg', 'image/png') } }

      it 'transitions to confirming state' do
        payment.check(params)
        expect(payment.payment_status).to eq('confirming')
      end
    end

    context 'when image is not present and merchant check is required' do
      let(:payment) { create(:payment, :deposit, :transferring) }
      let(:params) { { } }

      it 'does not transition to confirming state' do
        payment.check(params)
        expect(payment.payment_status).to eq('transferring')
      end
    end

    context 'when image is not present and merchant check is not required' do
      let(:payment) { create(:payment, :deposit, :transferring, merchant:) }
      let(:merchant) { create(:merchant, check_required: false) }
      let(:params) { { } }

      it 'transitions to confirming state' do
        payment.check(params)
        expect(payment.payment_status).to eq('confirming')
      end
    end
  end

  describe "#auditing" do
    it "audits changes to the payment model" do
      payment = create(:payment, :deposit)
      payment.update(payment_status: "completed")

      expect(payment.audits.count).to eq(2)
      expect(payment.audits.last.action).to eq("update")
      expect(payment.audits.last.audited_changes).to include("payment_status" => ["created", "completed"])
    end
  end
end


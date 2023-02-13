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
end


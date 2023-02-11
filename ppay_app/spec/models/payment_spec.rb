# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Payment, type: :model do
  it { is_expected.to have_many(:transactions) }

  it { is_expected.to belong_to(:rate_snapshot).optional(true) }
  it { is_expected.to belong_to(:advertisement).optional(true) }

  describe ":check event" do
    let(:payment) { create(:payment, payment_status: 'transferring', national_currency:'RUB', national_currency_amount:3000,
      redirect_url:'https://example.com/redirect_url', callback_url:'https://example.com/callback_url') }

    context "when the guard condition is false" do
      before do
        allow(payment).to receive(:valid_image?) { false }
      end

      it "does not transition to 'confirming'" do
        payment.check
        expect(payment.payment_status).to eq 'transferring'
      end
    end

    context "when the guard condition is true" do
      before do
        allow(payment).to receive(:valid_image?) { true }
      end

      it "does transition to 'confirming'" do
        payment.check
        expect(payment.payment_status).to eq 'confirming'
      end
    end

    context 'when merchant check is required' do
      before do
        allow(payment).to receive(:merchant).and_return(double(check_required: true))
      end

      context 'and image is not present' do
        let(:params) { {} }

        it 'returns false' do
          expect(payment.send(:valid_image?, params)).to be false
        end
      end
    end

    context 'when merchant check is not required' do
      before do
        allow(payment).to receive(:merchant).and_return(double(check_required: false))
      end

      context 'and image is not present' do
        let(:params) { {} }

        it 'returns true' do
          expect(payment.send(:valid_image?, params)).to be true
        end
      end
    end
  end
end

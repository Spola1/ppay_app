# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Payment, type: :model do
  let!(:ppay_user) { create(:user, :ppay) }
  let!(:rate_snapshot) { create(:rate_snapshot) }

  it { is_expected.to have_many(:transactions) }

  it { is_expected.to belong_to(:rate_snapshot).optional(true) }
  it { is_expected.to belong_to(:advertisement).optional(true) }

  context 'validation' do
    let(:payment1) { create :payment }
    let(:payment2) { create :payment, :cancelled }
    let(:payment3) { create :payment, :with_transactions, payment_status: }
    describe 'before_save' do
      context 'auto take off arbitration' do
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

      context 'cancel transaction' do
        let(:payment_status) { :cancelled }
        it 'sets transactions to cancelled status' do
          expect(payment3.transactions.map { |tr| tr['status'] }).to all(eq 'cancelled')
        end
      end

      context 'completed transaction' do
        let(:payment_status) { :completed }
        it 'sets transactions to cancelled status' do
          expect(payment3.transactions.map { |tr| tr['status'] }).to all(eq 'completed')
        end
      end
    end
  end

  describe ':bind event' do
    shared_examples 'changes payment status to transferring' do
      it do
        expect { payment1.bind }.to change { payment1.payment_status }.from('processer_search').to('transferring')
        expect { payment2.bind }.to change { payment2.payment_status }.from('processer_search').to('transferring')
        expect { payment3.bind }.to change { payment3.payment_status }.from('processer_search').to('transferring')
      end
    end

    describe '#ensure_unique_amount for deposits' do
      let(:advertisement) { create(:advertisement, :deposit) }
      let(:unique_amount) { nil }
      let(:payment1) { create(:payment, :deposit, :processer_search, advertisement:, unique_amount:) }
      let(:payment2) { create(:payment, :deposit, :processer_search, advertisement:, unique_amount:) }
      let(:payment3) { create(:payment, :deposit, :processer_search, advertisement:, unique_amount:) }

      it 'doesnt change amount' do
        expect { payment1.bind! }.not_to change { payment1.reload.national_currency_amount }.from(100)
        expect { payment2.bind! }.not_to change { payment2.reload.national_currency_amount }.from(100)
        expect { payment3.bind! }.not_to change { payment3.reload.national_currency_amount }.from(100)
      end

      it_behaves_like 'changes payment status to transferring'

      context 'when unique_amount is integer' do
        let(:unique_amount) { :integer }

        it 'changes amount depending on unique_amount' do
          expect { payment1.bind! }.not_to change { payment1.reload.national_currency_amount }.from(100)
          expect { payment2.bind! }.to     change { payment2.reload.national_currency_amount }.from(100).to(99)
          expect { payment3.bind! }.to     change { payment3.reload.national_currency_amount }.from(100).to(98)
        end

        it_behaves_like 'changes payment status to transferring'
      end

      context 'when unique_amount is decimal' do
        let(:unique_amount) { :decimal }

        it 'changes amount depending on unique_amount' do
          expect { payment1.bind! }.not_to change { payment1.reload.national_currency_amount }.from(100)
          expect { payment2.bind! }.to     change { payment2.reload.national_currency_amount }.from(100).to(99.99)
          expect { payment3.bind! }.to     change { payment3.reload.national_currency_amount }.from(100).to(99.98)
        end

        it_behaves_like 'changes payment status to transferring'
      end
    end

    describe '#ensure_unique_amount for withdrawals' do
      let(:advertisement) { create(:advertisement, :withdrawal) }
      let(:unique_amount) { nil }
      let(:payment1) { create(:payment, :withdrawal, :processer_search, advertisement:, unique_amount:) }
      let(:payment2) { create(:payment, :withdrawal, :processer_search, advertisement:, unique_amount:) }
      let(:payment3) { create(:payment, :withdrawal, :processer_search, advertisement:, unique_amount:) }

      shared_examples 'changes payment status to transferring' do
        it do
          expect { payment1.bind }.to change { payment1.payment_status }.from('processer_search').to('transferring')
          expect { payment2.bind }.to change { payment2.payment_status }.from('processer_search').to('transferring')
          expect { payment3.bind }.to change { payment3.payment_status }.from('processer_search').to('transferring')
        end
      end

      it 'doesnt change amount' do
        expect { payment1.bind! }.not_to change { payment1.reload.national_currency_amount }.from(100)
        expect { payment2.bind! }.not_to change { payment2.reload.national_currency_amount }.from(100)
        expect { payment3.bind! }.not_to change { payment3.reload.national_currency_amount }.from(100)
      end

      it_behaves_like 'changes payment status to transferring'

      context 'when unique_amount is integer' do
        let(:unique_amount) { :integer }

        it 'changes amount depending on unique_amount' do
          expect { payment1.bind! }.not_to change { payment1.reload.national_currency_amount }.from(100)
          expect { payment2.bind! }.to     change { payment2.reload.national_currency_amount }.from(100).to(101)
          expect { payment3.bind! }.to     change { payment3.reload.national_currency_amount }.from(100).to(102)
        end

        it_behaves_like 'changes payment status to transferring'
      end

      context 'when unique_amount is decimal' do
        let(:unique_amount) { :decimal }

        it 'changes amount depending on unique_amount' do
          expect { payment1.bind! }.not_to change { payment1.reload.national_currency_amount }.from(100)
          expect { payment2.bind! }.to     change { payment2.reload.national_currency_amount }.from(100).to(100.01)
          expect { payment3.bind! }.to     change { payment3.reload.national_currency_amount }.from(100).to(100.02)
        end

        it_behaves_like 'changes payment status to transferring'
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

  describe "cancellation_reason" do
    it { is_expected.to define_enum_for(:cancellation_reason).with_values(by_client: 0, duplicate_payment: 1, fraud_attempt: 2, incorrect_amount: 3)}
  end
end

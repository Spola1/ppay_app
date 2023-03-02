# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Payment, type: :model do
  let!(:ppay_user) { create(:user, :ppay) }
  let!(:rate_snapshot) { create(:rate_snapshot) }

  it { is_expected.to have_many(:transactions) }

  it { is_expected.to belong_to(:rate_snapshot).optional(true) }
  it { is_expected.to belong_to(:advertisement).optional(true) }

  context 'validation' do
    let(:payment1) { create :payment, arbitration: true }
    let(:payment2) { create :payment, :cancelled }
    let(:payment3) { create :payment, :with_transactions, payment_status: }

    describe 'before_save' do
      context 'auto take off arbitration' do
        context 'when status is not cancelled or completed and not changed' do
          before { payment1.update(payment_status: :transferring) }

          it 'arbitration should be true' do
            expect(payment1.arbitration).to eq(true)
          end
        end

        context 'when status is updating to completed' do
          before { payment1.update(payment_status: :completed) }

          it 'arbitration should be set to true' do
            expect(payment1.arbitration).to eq(false)
          end
        end

        context 'when status is updating to cancelled' do
          before { payment1.update(payment_status: :cancelled) }

          it 'arbitration should be set to true' do
            expect(payment1.arbitration).to eq(false)
          end
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

    describe '#transactions_cannot_be_completed_or_cancelled' do
      subject { payment.errors[:transactions] }

      let(:payment) { create(:payment, :with_transactions) }

      before { payment.update(payment_status: :draft) }

      it { is_expected.to be_empty }

      context 'completed transactions' do
        let(:payment) { create(:payment, :with_completed_transactions) }

        it { is_expected.to match_array(['already completed or cancelled']) }
      end

      context 'cancelled transactions' do
        let(:payment) { create(:payment, :with_completed_transactions) }

        it { is_expected.to match_array(['already completed or cancelled']) }
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

        context 'when different types' do
          let(:payment1) { create(:payment, :withdrawal, :processer_search, advertisement:, unique_amount:) }

          it 'changes amount depending on unique_amount' do
            expect { payment1.bind! }.not_to change { payment1.reload.national_currency_amount }.from(100)
            expect { payment2.bind! }.not_to change { payment2.reload.national_currency_amount }.from(100)
            expect { payment3.bind! }.to     change { payment3.reload.national_currency_amount }.from(100).to(99)
          end
        end
      end

      context 'when unique_amount is decimal' do
        let(:unique_amount) { :decimal }

        it 'changes amount depending on unique_amount' do
          expect { payment1.bind! }.not_to change { payment1.reload.national_currency_amount }.from(100)
          expect { payment2.bind! }.to change { payment2.reload.national_currency_amount }.from(100).to(99.99)
          expect { payment3.bind! }.to change { payment3.reload.national_currency_amount }.from(100).to(99.98)
        end

        it_behaves_like 'changes payment status to transferring'

        context 'when different types' do
          let(:payment1) { create(:payment, :withdrawal, :processer_search, advertisement:, unique_amount:) }

          it 'changes amount depending on unique_amount' do
            expect { payment1.bind! }.not_to change { payment1.reload.national_currency_amount }.from(100)
            expect { payment2.bind! }.not_to change { payment2.reload.national_currency_amount }.from(100)
            expect { payment3.bind! }.to     change { payment3.reload.national_currency_amount }.from(100).to(99.99)
          end
        end
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
      let(:params) { {} }

      it 'does not transition to confirming state' do
        payment.check(params)
        expect(payment.payment_status).to eq('transferring')
      end
    end

    context 'when image is not present and merchant check is not required' do
      let(:payment) { create(:payment, :deposit, :transferring, merchant:) }
      let(:merchant) { create(:merchant, check_required: false) }
      let(:params) { {} }

      it 'transitions to confirming state' do
        payment.check(params)
        expect(payment.payment_status).to eq('confirming')
      end
    end
  end

  describe '#auditing' do
    let(:payment) { create(:payment, :deposit, status_changed_at: nil) }

    before do
      payment.update(
        payment_status: 'completed',
        cancellation_reason: :duplicate_payment,
        unique_amount: :integer,
        payment_system: 'Tinkoff',
        national_currency: 'IDR',
        national_currency_amount: 1000,
        cryptocurrency_amount: 2,
        cryptocurrency: 'BTC',
        status_changed_at: Time.now.to_s
      )
    end

    it 'audits changes to the payment model' do
      expect(payment.audits.count).to eq(2)
      expect(payment.audits.last.action).to eq('update')
      expect(payment.audits.last.audited_changes).to include('payment_status' => %w[created completed],
                                                             'cancellation_reason' => [nil, 1],
                                                             'unique_amount' => [0, 1],
                                                             'payment_system' => %w[Sberbank Tinkoff],
                                                             'national_currency' => %w[RUB IDR],
                                                             'national_currency_amount' => ['100.0', '1000.0'],
                                                             'cryptocurrency_amount' => ['1.0', '2.0'],
                                                             'cryptocurrency' => %w[USDT BTC],
                                                             'status_changed_at' => [nil, payment.status_changed_at])
    end
  end

  describe 'cancellation_reason' do
    it {
      is_expected.to define_enum_for(:cancellation_reason).with_values(by_client: 0, duplicate_payment: 1, fraud_attempt: 2,
                                                                       incorrect_amount: 3)
    }
  end
end

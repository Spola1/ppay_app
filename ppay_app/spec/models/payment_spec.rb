# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Payment, type: :model do
  let!(:ppay_user) { create(:user, :ppay) }
  let!(:rate_snapshot) { create(:rate_snapshot) }
  let!(:rate_snapshot_sell) { create(:rate_snapshot, :sell) }
  let!(:national_currency_idr) { create(:national_currency, name: 'IDR') }

  it { is_expected.to have_many(:transactions) }

  it { is_expected.to belong_to(:rate_snapshot).optional(true) }
  it { is_expected.to belong_to(:advertisement).optional(true) }

  describe 'before_save' do
    describe 'take_off_arbitration' do
      let(:payment) { create :payment, payment_status: :processer_search, arbitration: true }

      context 'status does not change' do
        before { payment.update(national_currency_amount: (rand(1..1_000_000) / 100.0)) }
        it { expect(payment.arbitration).to eq true }
      end

      context 'status changes not to completed or cancelled' do
        %i[draft processer_search transferring confirming].each do |new_status|
          before { payment.update(payment_status: new_status) }
          it { expect(payment.arbitration).to eq true }
        end
      end

      context 'status changes to completed or cancelled' do
        %i[cancelled completed].each do |new_status|
          before { payment.update(payment_status: new_status) }
          it { expect(payment.arbitration).to eq false }
        end
      end
    end

    describe 'cancel/complete transactions' do
      let(:payment) { create :payment, :with_transactions, payment_status: :transferring }

      it { expect(payment.transactions.map(&:status)).to all(eq 'frozen') }

      context 'status changes to cancelled' do
        before { payment.update payment_status: :cancelled }
        it { expect(payment.transactions.map(&:status)).to all(eq 'cancelled') }
      end

      context 'status changes to completed' do
        before { payment.update payment_status: :completed }
        it { expect(payment.transactions.map(&:status)).to all(eq 'completed') }
      end
    end
  end

  describe '#transactions_cannot_be_completed_or_cancelled' do
    subject { payment.errors[:transactions] }

    context 'on status changes' do
      before { payment.update(payment_status: :draft) }

      context 'frozen transactions' do
        let(:payment) { create(:payment, :with_transactions) }

        it { is_expected.to be_empty }
      end

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
      let(:merchant) { create :merchant }
      let(:payment1) do
        create(:payment, :deposit, :processer_search, advertisement:, unique_amount:,
                                                      merchant:,
                                                      payment_system: payment_system.name)
      end
      let(:payment2) do
        create(:payment, :deposit, :processer_search, advertisement:, unique_amount:,
                                                      merchant:,
                                                      payment_system: payment_system.name)
      end
      let(:payment3) do
        create(:payment, :deposit, :processer_search, advertisement:, unique_amount:,
                                                      merchant:,
                                                      payment_system: payment_system.name)
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
          expect { payment2.bind! }.to     change { payment2.reload.national_currency_amount }.from(100).to(99)
          expect { payment3.bind! }.to     change { payment3.reload.national_currency_amount }.from(100).to(98)
        end

        it_behaves_like 'changes payment status to transferring'

        context 'when different types' do
          let(:payment1) do
            create(:payment, :withdrawal, :processer_search, advertisement:, unique_amount:,
                                                             merchant:,
                                                             payment_system: payment_system.name)
          end

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
          let(:payment1) do
            create(:payment, :withdrawal, :processer_search, advertisement:, unique_amount:,
                                                             merchant:,
                                                             payment_system: payment_system.name)
          end

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
      is_expected.to define_enum_for(:cancellation_reason).with_values(by_client: 0, duplicate_payment: 1,
                                                                       fraud_attempt: 2, incorrect_amount: 3,
                                                                       not_paid: 4, time_expired: 5)
    }
  end

  describe 'scope' do
    let!(:payment1) { create :payment, :by_client, :cancelled, :Tinkoff, cryptocurrency_amount:, external_order_id: }
    let!(:payment2) { create :payment, :IDR, created_at:, uuid: }
    let!(:payment3) { create :payment, :by_client, :Tinkoff, national_currency_amount: }
    let(:created_at)  { 'Mon, 06 Mar 2023 22:53:42.811063000 MSK +03:00' }
    let(:national_currency_amount) { 1000 }
    let(:cryptocurrency_amount) { 111 }
    let(:uuid) { '06e2f816-3d85-4c0d-b5d7-c1729b3d4ac2' }
    let(:external_order_id) { '5678' }

    describe 'filter_by_created_from' do
      context 'when 03.09.2023' do
        subject(:payment) { Payment.filter_by_created_from('03.09.2023') }
        let(:correct_result) { [payment3, payment1] }
        it { expect(payment.to_a).to eq(correct_result) }
      end
    end

    describe 'filter_by_created_to' do
      context 'when 03.09.2023' do
        subject(:payment) { Payment.filter_by_created_to('03.09.2023') }
        let(:correct_result) { [payment2] }
        it { expect(payment.to_a).to eq(correct_result) }
      end
    end

    describe 'filter_by_cancellation_reason' do
      context 'when by_client' do
        subject(:payment) { Payment.filter_by_cancellation_reason('by_client') }
        let(:correct_result) { [payment3, payment1] }
        it { expect(payment.to_a).to eq(correct_result) }
      end
    end

    describe 'filter_by_payment_status' do
      context 'when cancelled' do
        subject(:payment) { Payment.filter_by_payment_status('cancelled') }
        let(:correct_result) { [payment1] }
        it { expect(payment.to_a).to eq(correct_result) }
      end
    end

    describe 'filter_by_national_currency' do
      context 'when RUB' do
        subject(:payment) { Payment.filter_by_national_currency('RUB') }
        let(:correct_result) { [payment3, payment1] }
        it { expect(payment.to_a).to eq(correct_result) }
      end
    end

    describe 'filter_by_payment_system' do
      context 'when Tinkoff' do
        subject(:payment) { Payment.filter_by_payment_system('Tinkoff') }
        let(:correct_result) { [payment3, payment1] }
        it { expect(payment.to_a).to eq(correct_result) }
      end
    end

    describe 'filter_by_national_currency_amount_from' do
      context 'when 500' do
        subject(:payment) { Payment.filter_by_national_currency_amount_from('500') }
        let(:correct_result) { [payment3] }
        it { expect(payment.to_a).to eq(correct_result) }
      end
    end

    describe 'filter_by_national_currency_amount_to' do
      context 'when 500' do
        subject(:payment) { Payment.filter_by_national_currency_amount_to('500') }
        let(:correct_result) { [payment1, payment2] }
        it { expect(payment.to_a).to eq(correct_result) }
      end
    end

    describe 'filter_by_cryptocurrency_amount_from' do
      context 'when 50' do
        subject(:payment) { Payment.filter_by_cryptocurrency_amount_from('50') }
        let(:correct_result) { [payment1] }
        it { expect(payment.to_a).to eq(correct_result) }
      end
    end

    describe 'filter_by_cryptocurrency_amount_to' do
      context 'when 50' do
        subject(:payment) { Payment.filter_by_cryptocurrency_amount_to('50') }
        let(:correct_result) { [payment3, payment2] }
        it { expect(payment.to_a).to eq(correct_result) }
      end
    end

    describe 'filter_by_uuid' do
      subject(:payment) { Payment.filter_by_uuid('06e2f816-3d85-4c0d-b5d7-c1729b3d4ac2') }
      let(:correct_result) { [payment2] }
      it { expect(payment.to_a).to eq(correct_result) }
    end

    describe 'filter_by_part_of_uuid' do
      subject(:payment) { Payment.filter_by_uuid('c1729b') }
      let(:correct_result) { [payment2] }
      it { expect(payment.to_a).to eq(correct_result) }
    end

    describe 'filter_by_external_order_id' do
      subject(:payment) { Payment.filter_by_external_order_id('5678') }
      let(:correct_result) { [payment1] }
      it { expect(payment.to_a).to eq(correct_result) }
    end
  end
end

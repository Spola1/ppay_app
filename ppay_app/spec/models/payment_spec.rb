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

  describe '.in_deposit_flow_hotlist' do
    let(:adv) { create(:advertisement) }
    let(:payment1) { create(:payment, :deposit, :confirming, advertisement: adv) }
    let(:payment2) { create(:payment, :deposit, :transferring, advertisement: adv) }
    let(:payment3) { create(:payment, :deposit, :confirming, arbitration: true, advertisement: adv) }
    let(:payment4) { create(:payment, :deposit, :processer_search, advertisement: adv) }

    it 'returns payments in the deposit flow hotlist' do
      result = adv.payments.in_deposit_flow_hotlist

      expect(result).to eq([payment1, payment2, payment3])
    end
  end

  describe '.in_withdrawal_flow_hotlist' do
    let(:adv) { create(:advertisement, :withdrawal) }
    let(:payment1) { create(:payment, :withdrawal, :confirming, advertisement: adv) }
    let(:payment2) { create(:payment, :withdrawal, :transferring, advertisement: adv) }
    let(:payment3) { create(:payment, :withdrawal, :confirming, arbitration: true, advertisement: adv) }
    let(:payment4) { create(:payment, :withdrawal, :processer_search, advertisement: adv) }

    it 'returns payments in the withdrawal flow hotlist' do
      result = adv.payments.in_withdrawal_flow_hotlist

      expect(result).to eq([payment2, payment1, payment3])
    end
  end

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
      let(:advertisement) { create(:advertisement) }
      let(:unique_amount) { :none }
      let(:merchant) { create :merchant, unique_amount: }
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
    let(:payment) { create(:payment, :deposit) }

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
        status_changed_at: Time.now
      )
    end

    it 'audits changes to the payment model' do
      expect(payment.audits.count).to eq(2)
      expect(payment.audits.last.action).to eq('update')
      expect(payment.audits.last.audited_changes).to include(
        'payment_status' => %w[created completed],
        'cancellation_reason' => [nil, 1],
        'unique_amount' => [0, 1],
        'payment_system' => %w[Sberbank Tinkoff],
        'national_currency' => %w[RUB IDR],
        'national_currency_amount' => ['100.0', '1000.0'],
        'cryptocurrency_amount' => ['1.0', '2.0'],
        'cryptocurrency' => %w[USDT BTC],
        'status_changed_at' => [a_kind_of(String), payment.reload.status_changed_at.iso8601(3)]
      )
    end
  end

  describe 'cancellation_reason' do
    it {
      is_expected.to define_enum_for(:cancellation_reason).with_values(by_client: 0, duplicate_payment: 1,
                                                                       fraud_attempt: 2, incorrect_amount: 3,
                                                                       not_paid: 4, time_expired: 5)
    }
  end

  describe 'filter scope' do
    let!(:payment1) do
      create(:payment, :by_client, :cancelled, :Tinkoff, cryptocurrency_amount:, external_order_id:,
                                                         created_at: Time.zone.parse('2023-09-03 23:53:42'),
                                                         advertisement: advertisement1)
    end
    let!(:payment2) do
      create(:payment, :IDR, created_at: Time.zone.parse('2023-09-02 23:59:59'), uuid:,
                             advertisement: advertisement1)
    end
    let!(:payment3) do
      create(:payment, :by_client, :Tinkoff, national_currency_amount:,
                                             created_at: Time.zone.parse('2023-09-03 01:00:56'),
                                             advertisement: advertisement2)
    end

    let!(:advertisement1) do
      create(:advertisement, card_number: '1234123412341234', id: 1)
    end

    let!(:advertisement2) do
      create(:advertisement, card_number: '1111111111111111', id: 2)
    end

    let(:national_currency_amount) { 1000 }
    let(:cryptocurrency_amount) { 111 }
    let(:uuid) { '06e2f816-3d85-4c0d-b5d7-c1729b3d4ac2' }
    let(:external_order_id) { '5678' }

    describe 'filter_by_created_from' do
      context 'when 03.09.2023' do
        subject(:payments) do
          Payment.filter_by_created_from(
            Time.zone.parse('2023-09-03 23:59:59')
          ) # later than payment1, payment2, but scopes beginning_of_day
        end
        let(:correct_result) { [payment1, payment3] }

        it 'returns payments created from the specified date' do
          expect(payments).to contain_exactly(*correct_result)
        end
      end
    end

    describe 'filter_by_card_number' do
      context 'when 1111111111111111' do
        subject(:payments) { Payment.filter_by_card_number('1111111111111111') }
        let(:correct_result) { [payment3] }

        it 'returns payments with 1111111111111111 card_number' do
          expect(payments).to eq(correct_result)
        end
      end
    end

    describe 'filter_by_advertisement_id' do
      context 'when id 1' do
        subject(:payments) { Payment.filter_by_advertisement_id('1') }
        let(:correct_result) { [payment1, payment2] }

        it 'returns payments with advertisement_id = 1' do
          expect(payments).to eq(correct_result)
        end
      end
    end

    describe 'filter_by_created_to' do
      context 'when 03.09.2023' do
        subject(:payments) { Payment.filter_by_created_to(Time.parse('2023-09-03 23:59:59').in_time_zone('Moscow')) }
        let(:correct_result) { [payment1, payment3, payment2] }

        it 'returns payments created before the specified date' do
          expect(payments).to eq(correct_result)
        end
      end
    end

    describe 'filter_by_cancellation_reason' do
      context 'when by_client' do
        subject(:payment) { Payment.filter_by_cancellation_reason('by_client') }
        let(:correct_result) { [payment1, payment3] }
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
        let(:correct_result) { [payment1, payment3] }
        it { expect(payment.to_a).to eq(correct_result) }
      end
    end

    describe 'filter_by_payment_system' do
      context 'when Tinkoff' do
        subject(:payment) { Payment.filter_by_payment_system('Tinkoff') }
        let(:correct_result) { [payment1, payment3] }
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

  describe 'scope' do
    let!(:payment1) { create :payment, :deposit, status_changed_at: }
    let!(:payment2) { create :payment, :withdrawal, :arbitration }
    let!(:payment3) { create :payment, :deposit, :arbitration }
    let(:arbitration) { true }
    let(:status_changed_at) { Time.now - 21.minutes }

    context 'when deposits' do
      subject(:payment) { Payment.deposits }
      let(:correct_result) { [payment3, payment1] }
      it { expect(payment.to_a).to eq(correct_result) }
    end

    context 'when not only deposits' do
      subject(:payment) { Payment.deposits }
      let(:correct_result) { [payment3, payment2, payment1] }
      it { expect(payment.to_a).not_to eq(correct_result) }
    end

    context 'when withdrawals' do
      subject(:payment) { Payment.withdrawals }
      let(:correct_result) { [payment2] }
      it { expect(payment.to_a).to eq(correct_result) }
    end

    context 'when not only withdrawals' do
      subject(:payment) { Payment.withdrawals }
      let(:correct_result) { [payment2, payment1] }
      it { expect(payment.to_a).not_to eq(correct_result) }
    end

    context 'when arbitarrion' do
      subject(:payment) { Payment.arbitration }
      let(:correct_result) { [payment3, payment2] }
      it { expect(payment.to_a).to eq(correct_result) }
    end

    context 'when not only arbitration' do
      subject(:payment) { Payment.arbitration }
      let(:correct_result) { [payment3, payment2, payment1] }
      it { expect(payment.to_a).not_to eq(correct_result) }
    end

    context 'when expired' do
      subject(:payment) { Payment.expired }
      let(:correct_result) { [payment1] }
      it { expect(payment.to_a).to eq(correct_result) }
    end

    context 'when not only expired' do
      subject(:payment) { Payment.expired }
      let(:correct_result) { [payment1, payment3] }
      it { expect(payment.to_a).not_to eq(correct_result) }
    end
  end

  describe 'active scope' do
    let!(:payment1) { create :payment, :created }
    let!(:payment2) { create :payment, :transferring }
    let!(:payment3) { create :payment, :confirming }
    let!(:payment4) { create :payment, :cancelled }
    let!(:payment5) { create :payment, :completed }

    context 'when active' do
      subject(:payment) { Payment.active }
      let(:correct_result) { [payment3, payment2, payment1] }
      it { expect(payment.to_a).to eq(correct_result) }
    end

    context 'when not only active' do
      subject(:payment) { Payment.active }
      let(:correct_result) { [payment5, payment4, payment3, payment2, payment1] }
      it { expect(payment.to_a).not_to eq(correct_result) }
    end

    context 'when not active' do
      subject(:payment) { Payment.active }
      let(:correct_result) { [payment5, payment4] }
      it { expect(payment.to_a).not_to eq(correct_result) }
    end
  end

  describe 'in_hotlist scope' do
    let!(:payment1) { create :payment, :deposit, :confirming }
    let!(:payment2) { create :payment, :withdrawal, :transferring }
    let!(:payment3) { create :payment, :deposit, :transferring }
    let!(:payment4) { create :payment, :withdrawal, :confirming }

    context 'when in hotlist' do
      subject(:payment) { Payment.in_hotlist }
      let(:correct_result) { [payment2, payment1] }
      it { expect(payment.to_a).to eq(correct_result) }
    end

    context 'when not all payments in hotlist' do
      subject(:payment) { Payment.in_hotlist }
      let(:correct_result) { [payment3, payment2, payment1] }
      it { expect(payment.to_a).not_to eq(correct_result) }
    end

    context 'when not in hotlist' do
      subject(:payment) { Payment.in_hotlist }
      let(:correct_result) { [payment4, payment3] }
      it { expect(payment.to_a).not_to eq(correct_result) }
    end
  end

  describe 'initial_amount' do
    let!(:payment1) { create :payment, national_currency_amount: }
    let(:national_currency_amount) { 1000 }

    subject { payment1.initial_amount }

    it { is_expected.to eq(payment1.national_currency_amount) }
  end

  describe 'unique_amount' do
    let!(:merchant1) { create :merchant, unique_amount: unique_amount1 }
    let!(:merchant2) { create :merchant, unique_amount: unique_amount2 }
    let!(:payment1) { create :payment, merchant: merchant1 }
    let(:unique_amount1) { :integer }
    let(:unique_amount2) { :decimal }

    subject { payment1.unique_amount }

    it { is_expected.to eq(merchant1.unique_amount) }
    it { is_expected.not_to eq(merchant2.unique_amount) }
  end

  describe '#set_locale_from_currency' do
    let(:payment) { create :payment, payment_status: :created }

    context 'when locale is blank' do
      it 'sets locale based on currency' do
        payment.send(:set_locale_from_currency)
        expect(payment.locale).to eq('ru')
      end
    end

    context 'when locale is already set' do
      it 'does not change the locale' do
        payment.locale = 'kk'
        payment.send(:set_locale_from_currency)
        expect(payment.locale).to eq('kk')
      end
    end
  end

  describe '#currency_to_locale' do
    let(:payment) { create :payment, payment_status: :created }

    it 'returns locale based on currency' do
      expect(payment.send(:currency_to_locale, 'RUB')).to eq(:ru)
      expect(payment.send(:currency_to_locale, 'UZS')).to eq(:uz)
    end
  end

  describe '.expired_arbitration_not_paid' do
    let!(:not_expired_arbitration) do
      create(:payment, payment_status: :transferring, arbitration: true, arbitration_reason: :not_paid,
                       status_changed_at: 5.minutes.ago)
    end
    let!(:expired_arbitration_not_paid) do
      create(:payment, arbitration: true, payment_status: :transferring, arbitration_reason: :not_paid,
                       status_changed_at: 15.minutes.ago)
    end
    let!(:expired_arbitration_other_reason) do
      create(:payment, arbitration: true, payment_status: :transferring, arbitration_reason: :fraud_attempt,
                       status_changed_at: 15.minutes.ago)
    end

    it 'includes expired arbitration with not_paid reason' do
      expect(Payment.expired_arbitration_not_paid).to include(expired_arbitration_not_paid)
    end

    it 'excludes not expired arbitration with not_paid reason' do
      expect(Payment.expired_arbitration_not_paid).not_to include([not_expired_arbitration,
                                                                   expired_arbitration_other_reason])
    end

    it 'excludes expired arbitration with other reason' do
      expect(Payment.expired_arbitration_not_paid).not_to include(expired_arbitration_other_reason)
    end
  end

  describe '.expired_autoconfirming' do
    let!(:not_expired_autoconfirming) do
      create(:payment, autoconfirming: true, payment_status: :confirming, status_changed_at: 2.minutes.ago)
    end
    let!(:expired_autoconfirming) do
      create(:payment, autoconfirming: true, payment_status: :confirming, status_changed_at: 8.minutes.ago)
    end
    let!(:expired_autoconfirming_other_status) do
      create(:payment, autoconfirming: true, payment_status: :transferring, status_changed_at: 8.minutes.ago)
    end

    it 'includes expired autoconfirming with confirming status' do
      expect(Payment.expired_autoconfirming).to include(expired_autoconfirming)
    end

    it 'excludes not expired autoconfirming with confirming status' do
      expect(Payment.expired_autoconfirming).not_to include(not_expired_autoconfirming)
    end

    it 'excludes expired autoconfirming with other status' do
      expect(Payment.expired_autoconfirming).not_to include(expired_autoconfirming_other_status)
    end
  end

  describe '.arbitration_by_check' do
    let!(:adv) { create(:advertisement) }
    let!(:payment1) do
      create(:payment, :deposit, :confirming, advertisement: adv, arbitration: true, arbitration_reason: 5)
    end
    let!(:payment2) do
      create(:payment, :deposit, :confirming, advertisement: adv, arbitration: true, arbitration_reason: 2)
    end
    let!(:payment3) do
      create(:payment, :deposit, :confirming, advertisement: adv, arbitration: true, arbitration_reason: 6)
    end
    let!(:payment4) { create(:payment, :deposit, :confirming, advertisement: adv, arbitration_reason: 5) }

    it 'returns payments in the arbitration by check' do
      result = adv.payments.arbitration_by_check

      expect(result).to eq([payment3, payment1])
    end
  end
end

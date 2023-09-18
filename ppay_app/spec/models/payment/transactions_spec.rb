# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Payment transactions commissions' do
  let!(:ppay_user) { create :user, :ppay }
  let!(:rate_snapshot_buy) { create :rate_snapshot, value: 101.01 }
  let!(:rate_snapshot_sell) { create :rate_snapshot, :sell, value: 99.99 }

  let!(:merchant) { create(:merchant) }

  let(:commissions_values) do
    { # ppay processer agent  working_group other
      Deposit: [1, 0.5, 0.1, 0.2, 5],
      Withdrawal: [1.01, 0.505, 0.101, 0.202, 5.05]
    }
  end

  before do
    %i[Deposit Withdrawal].each do |direction|
      %i[ppay processer agent working_group other].each_with_index do |commission_type, ci|
        Commission.find_by(
          commission_type:,
          merchant_method: MerchantMethod.find_by({ merchant:, direction:, payment_system: })
        ).update(commission: commissions_values[direction][ci])
      end
    end
  end

  let(:advertisement) { create(:advertisement, processer:) }

  let(:national_currency_amount) { 100 }
  let(:cryptocurrency_amount) do
    number_with_precision(
      rate_snapshot.to_crypto(national_currency_amount, merchant.fee_percentage),
      precision: 64
    ).to_d
  end

  let(:processer_commission) { 3.to_d }
  let(:working_group_commission) { 1.5.to_d }
  let(:processer_withdrawal_commission) { 3.03.to_d }
  let(:working_group_withdrawal_commission) { 1.515.to_d }
  let(:processer) do
    create(:processer, processer_commission:, working_group_commission:,
                       processer_withdrawal_commission:, working_group_withdrawal_commission:)
  end

  context 'when deposit binds to advertisement' do
    let(:payment) do
      create :payment, :deposit, :processer_search,
             national_currency_amount:,
             advertisement:,
             merchant:
    end

    let(:rate_snapshot) { rate_snapshot_buy }

    before { payment.bind! }

    it 'transactions sum equals payment\'s cryptocurrency amount' do
      expect(payment.transactions.map(&:amount).sum).to eq(cryptocurrency_amount)
    end

    it 'ppay transaction meets it\'s commission percent' do
      expect(payment.transactions.find_by(transaction_type: :ppay_commission).amount)
        .to eq(cryptocurrency_amount * (commissions_values[:Deposit][4] -
                                        processer_commission -
                                        working_group_commission) / 100)
    end

    it 'processer transaction meets it\'s commission percent' do
      expect(payment.transactions.find_by(transaction_type: :processer_commission).amount)
        .to eq(cryptocurrency_amount * processer_commission / 100)
    end

    it 'agent transaction meets it\'s commission percent' do
      expect(payment.transactions.find_by(transaction_type: :agent_commission).amount)
        .to eq(cryptocurrency_amount * commissions_values[:Deposit][2] / 100)
    end

    it 'working_group transaction meets it\'s commission percent' do
      expect(payment.transactions.find_by(transaction_type: :working_group_commission).amount)
        .to eq(cryptocurrency_amount * working_group_commission / 100)
    end
  end

  context 'when withdrawal binds to advertisement' do
    let(:payment) do
      create :payment, :withdrawal, :processer_search,
             national_currency_amount:,
             advertisement:,
             merchant:
    end

    let(:rate_snapshot) { rate_snapshot_sell }

    before { payment.bind! }

    it 'transactions sum equals payment\'s cryptocurrency amount' do
      expect(payment.transactions.map(&:amount).sum)
        .to eq(cryptocurrency_amount * (1 + ((commissions_values[:Withdrawal][2] +
                                              commissions_values[:Withdrawal][4]) / 100)))
    end

    it 'ppay transaction meets it\'s commission percent' do
      expect(payment.transactions.find_by(transaction_type: :ppay_commission).amount)
        .to eq(cryptocurrency_amount * (commissions_values[:Withdrawal][4] -
                                        processer_withdrawal_commission -
                                        working_group_withdrawal_commission) / 100)
    end

    it 'processer transaction meets it\'s commission percent' do
      expect(payment.transactions.find_by(transaction_type: :processer_commission).amount)
        .to eq(cryptocurrency_amount * processer_withdrawal_commission / 100)
    end

    it 'agent transaction meets it\'s commission percent' do
      expect(payment.transactions.find_by(transaction_type: :agent_commission).amount)
        .to eq(cryptocurrency_amount * commissions_values[:Withdrawal][2] / 100)
    end

    it 'working_group transaction meets it\'s commission percent' do
      expect(payment.transactions.find_by(transaction_type: :working_group_commission).amount)
        .to eq(cryptocurrency_amount * working_group_withdrawal_commission / 100)
    end
  end
end

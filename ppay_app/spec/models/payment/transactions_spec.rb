# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Payment transactions commissions' do
  let!(:ppay_user) { create(:user, :ppay) }
  let!(:rate_snapshot) { create(:rate_snapshot) }

  let(:merchant) { create :merchant }

  let(:commissions_values) do
    [ # ppay processer agent working_group
      [1,     0.5,      0.1,      0.2], # Deposit
      [1,     0.5,      0.1,      0.2]  # Withdrawal
    ].flatten
  end

  before do
    %w[Deposit Withdrawal].each_with_index do |direction, di|
      %i[ppay processer agent working_group].each_with_index do |commission_type, ci|
        Commission.find_by(
          commission_type:,
          merchant_method: MerchantMethod.find_by(
            {
              merchant:,
              direction:,
              payment_system:
            }
          )
        ).update(commission: commissions_values[(di * 4) + ci])
      end
    end
  end

  let(:advertisement) { create(:advertisement, :deposit) }

  let(:national_currency_amount) { 100 }
  let(:cryptocurrency_amount) do
    number_with_precision(
      rate_snapshot.to_crypto(national_currency_amount),
      precision: 2
    ).to_d
  end

  let(:payment) do
    create :payment, :deposit, :processer_search,
           national_currency_amount:,
           advertisement:,
           merchant:,
           payment_system: payment_system.name
  end

  context 'when payment binds to advertisement' do
    before { payment.bind! }

    it 'transactions sum equals payment\'s cryptocurrency amount' do
      expect(payment.transactions.map(&:amount).sum).to eq(cryptocurrency_amount)
    end

    it 'ppay transaction meets it\'s commission percent' do
      expect(payment.transactions.find_by(transaction_type: :ppay_commission).amount)
        .to eq(cryptocurrency_amount * commissions_values[0] / 100)
    end

    it 'processer transaction meets it\'s commission percent' do
      expect(payment.transactions.find_by(transaction_type: :processer_commission).amount)
        .to eq(cryptocurrency_amount * commissions_values[1] / 100)
    end

    it 'agent transaction meets it\'s commission percent' do
      expect(payment.transactions.find_by(transaction_type: :agent_commission).amount)
        .to eq(cryptocurrency_amount * commissions_values[2] / 100)
    end

    it 'working_group transaction meets it\'s commission percent' do
      expect(payment.transactions.find_by(transaction_type: :working_group_commission).amount)
        .to eq(cryptocurrency_amount * commissions_values[3] / 100)
    end
  end
end

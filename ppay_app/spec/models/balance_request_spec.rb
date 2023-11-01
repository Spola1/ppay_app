# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BalanceRequest, type: :model do
  let!(:balance_request) { create :balance_request, :deposit }

  it { is_expected.to have_one(:balance_transaction).class_name('Transaction') }
  it { is_expected.to belong_to(:user) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:crypto_address) }
    it { is_expected.to validate_numericality_of(:amount).is_greater_than(0) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:requests_type).with_values(deposit: 0, withdraw: 1) }
    it { is_expected.to define_enum_for(:status).with_values(processing: 0, completed: 1, cancelled: 2) }
  end

  describe '#set_crypto_address' do
    it 'should return balance request crypto address equal to balance request user crypto wallet address' do
      expect(balance_request.crypto_address).to eq(balance_request.user.crypto_wallet.address)
    end
  end

  describe ':complete event' do
    it 'transitions to completed state' do
      balance_request.complete!
      expect(balance_request.status).to eq('completed')
      expect(balance_request.user.balance.amount.to_i).to eq(1001)
    end
  end

  describe ':cancel event' do
    it 'transitions to cancelled state' do
      balance_request.cancel!
      expect(balance_request.status).to eq('cancelled')
      expect(balance_request.user.balance.amount.to_i).to eq(1000)
    end
  end

  describe 'requests_type' do
    it {
      is_expected.to define_enum_for(:requests_type).with_values(deposit: 0, withdraw: 1)
    }
  end

  describe 'status' do
    it {
      is_expected.to define_enum_for(:status).with_values(processing: 0, completed: 1, cancelled: 2)
    }
  end
end

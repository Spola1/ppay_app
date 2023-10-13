# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Balance, type: :model do
  it { is_expected.to have_many(:from_transactions).class_name('Transaction').with_foreign_key(:from_balance_id) }
  it { is_expected.to have_many(:to_transactions).class_name('Transaction').with_foreign_key(:to_balance_id) }
  it { is_expected.to belong_to(:balanceable) }

  describe 'validations' do
    it { is_expected.to validate_numericality_of(:amount).is_greater_than_or_equal_to(0) }
  end

  describe '#withdraw' do
    let(:processer1) { create(:processer) }

    context 'when the amount is less than the balance' do
      it 'subtracts the amount from the balance' do
        processer1.balance.withdraw(500, 500)
        expect(processer1.balance.amount).to eq(500)
      end

      it 'saves the updated balance' do
        processer1.balance.withdraw(500, 500)
        expect(processer1.balance.reload.amount).to eq(500)
      end
    end

    context 'when the amount is equal to the balance' do
      it 'subtracts the amount from the balance' do
        processer1.balance.withdraw(1000, 1000)
        expect(processer1.balance.amount).to eq(0)
      end

      it 'saves the updated balance' do
        processer1.balance.withdraw(1000, 1000)
        expect(processer1.balance.reload.amount).to eq(0)
      end
    end

    context 'when the amount is greater than the balance' do
      it 'raises an error and does not update the balance' do
        expect { processer1.balance.withdraw(1001, 1001) }.to raise_error(ActiveRecord::RecordInvalid)
        expect(processer1.balance.reload.amount).to eq(1000)
      end
    end

    context 'when subtracts a negative amount' do
      it 'raises an error and does not change the balance' do
        expect { processer1.balance.withdraw(-500, -500) }.to raise_error(ArgumentError, 'Amount must be positive')
        expect(processer1.balance.amount).to eq(1000)
      end

      it 'raises an error and does not update the balance' do
        expect { processer1.balance.withdraw(-500, -500) }.to raise_error(ArgumentError, 'Amount must be positive')
        expect(processer1.balance.reload.amount).to eq(1000)
      end
    end
  end

  describe '#deposit' do
    let(:processer1) { create(:processer) }

    context 'when depositing a positive amount' do
      it 'adds the amount to the balance' do
        processer1.balance.deposit(500, 500)
        expect(processer1.balance.amount).to eq(1500)
      end

      it 'saves the updated balance' do
        processer1.balance.deposit(500, 500)
        expect(processer1.balance.reload.amount).to eq(1500)
      end
    end

    context 'when depositing a zero amount' do
      it 'does not change the balance' do
        expect { processer1.balance.deposit(0, 0) }.to raise_error(ArgumentError, 'Amount must be positive')
        expect(processer1.balance.amount).to eq(1000)
      end

      it 'does not save the balance' do
        expect { processer1.balance.deposit(0, 0) }.to raise_error(ArgumentError, 'Amount must be positive')
        expect(processer1.balance.reload.amount).to eq(1000)
      end
    end

    context 'when depositing a negative amount' do
      it 'raises an error and does not change the balance' do
        expect { processer1.balance.deposit(-500, -500) }.to raise_error(ArgumentError, 'Amount must be positive')
        expect(processer1.balance.amount).to eq(1000)
      end

      it 'raises an error and does not update the balance' do
        expect { processer1.balance.deposit(-500, -500) }.to raise_error(ArgumentError, 'Amount must be positive')
        expect(processer1.balance.reload.amount).to eq(1000)
      end
    end
  end

  describe '#today_change' do
    let(:processer) { create :processer }
    let(:balance) { processer.balance }

    context 'when there are no transactions' do
      it 'returns 0' do
        expect(balance.today_change).to eq(0)
      end
    end

    context 'when there are transactions but not today' do
      let!(:transaction1) do
        create(:transaction, to_balance: balance, amount: 100, created_at: Date.today - 1.day)
      end
      let!(:transaction2) do
        create(:transaction, from_balance: balance, amount: 50, created_at: Date.today - 1.day)
      end

      it 'returns 0' do
        expect(balance.today_change).to eq(0)
      end
    end

    context 'when there are multiple transactions today' do
      let!(:transaction1) do
        create(:transaction, to_balance: balance, amount: 100, created_at: Time.zone.now - 23.hours,
                             status: :completed)
      end
      let!(:transaction2) do
        create(:transaction, to_balance: balance, amount: 50, created_at: Time.zone.now - 1.hours,
                             status: :completed)
      end
      let!(:transaction3) do
        create(:transaction, from_balance: balance, amount: 75, created_at: Time.zone.now - 8.hours,
                             status: :completed)
      end

      it 'returns the difference between today to and from transactions' do
        expect(balance.today_change).to eq(75)
      end
    end

    context 'when there are negative from transactions and positive to transactions today' do
      let!(:transaction1) do
        create(:transaction, to_balance: balance, amount: 100, created_at: Time.zone.now - 23.hours,
                             status: :completed)
      end
      let!(:transaction2) do
        create(:transaction, from_balance: balance, amount: 150, created_at: Time.zone.now - 1.hours, status: :completed)
      end

      it 'returns a negative number' do
        expect(balance.today_change).to eq(-50)
      end
    end

    context 'when there are only negative from transactions today' do
      let!(:transaction) do
        create(:transaction, from_balance: balance, amount: 75, created_at: Time.zone.now,
                             status: :completed)
      end

      it 'returns a negative number' do
        expect(balance.today_change).to eq(-75)
      end
    end

    context 'when there are only positive to transactions today' do
      let!(:transaction) do
        create(:transaction, to_balance: balance, amount: 100, created_at: Time.zone.now,
                             status: :completed)
      end

      it 'returns a positive number' do
        expect(balance.today_change).to eq(100)
      end
    end
  end

  describe '#transactions' do
    subject { processer.balance.transactions }

    let(:processer) { create :processer }
    let(:merchant) { create :merchant }
    let!(:from_transaction) do
      create :transaction, :completed, from_balance: processer.balance,
                                       to_balance: merchant.balance
    end
    let!(:frozen_from_transaction) do
      create :transaction, :frozen, from_balance: processer.balance,
                                    to_balance: merchant.balance
    end
    let!(:to_transaction) do
      create :transaction, :completed, from_balance: merchant.balance,
                                       to_balance: processer.balance
    end
    let!(:frozen_to_transaction) do
      create :transaction, :frozen, from_balance: merchant.balance,
                                    to_balance: processer.balance
    end

    it 'includes all transactions except frozen_to_transaction' do
      is_expected.to include(from_transaction, frozen_from_transaction, to_transaction)
      is_expected.not_to include(frozen_to_transaction)
    end
  end
end

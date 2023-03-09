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
        processer1.balance.withdraw(500)
        expect(processer1.balance.amount).to eq(500)
      end

      it 'saves the updated balance' do
        processer1.balance.withdraw(500)
        expect(processer1.balance.reload.amount).to eq(500)
      end
    end

    context 'when the amount is equal to the balance' do
      it 'subtracts the amount from the balance' do
        processer1.balance.withdraw(1000)
        expect(processer1.balance.amount).to eq(0)
      end

      it 'saves the updated balance' do
        processer1.balance.withdraw(1000)
        expect(processer1.balance.reload.amount).to eq(0)
      end
    end

    context 'when the amount is greater than the balance' do
      it 'raises an error and does not update the balance' do
        expect { processer1.balance.withdraw(1001) }.to raise_error(ActiveRecord::RecordInvalid)
        expect(processer1.balance.reload.amount).to eq(1000)
      end
    end

    context 'when subtracts a negative amount' do
      it 'raises an error and does not change the balance' do
        expect { processer1.balance.withdraw(-500) }.to raise_error(ArgumentError, 'Amount must be positive')
        expect(processer1.balance.amount).to eq(1000)
      end

      it 'raises an error and does not update the balance' do
        expect { processer1.balance.withdraw(-500) }.to raise_error(ArgumentError, 'Amount must be positive')
        expect(processer1.balance.reload.amount).to eq(1000)
      end
    end
  end

  describe '#deposit' do
    let(:processer1) { create(:processer) }

    context 'when depositing a positive amount' do
      it 'adds the amount to the balance' do
        processer1.balance.deposit(500)
        expect(processer1.balance.amount).to eq(1500)
      end

      it 'saves the updated balance' do
        processer1.balance.deposit(500)
        expect(processer1.balance.reload.amount).to eq(1500)
      end
    end

    context 'when depositing a zero amount' do
      it 'does not change the balance' do
        expect { processer1.balance.deposit(0) }.to raise_error(ArgumentError, 'Amount must be positive')
        expect(processer1.balance.amount).to eq(1000)
      end

      it 'does not save the balance' do
        expect { processer1.balance.deposit(0) }.to raise_error(ArgumentError, 'Amount must be positive')
        expect(processer1.balance.reload.amount).to eq(1000)
      end
    end

    context 'when depositing a negative amount' do
      it 'raises an error and does not change the balance' do
        expect { processer1.balance.deposit(-500) }.to raise_error(ArgumentError, 'Amount must be positive')
        expect(processer1.balance.amount).to eq(1000)
      end

      it 'raises an error and does not update the balance' do
        expect { processer1.balance.deposit(-500) }.to raise_error(ArgumentError, 'Amount must be positive')
        expect(processer1.balance.reload.amount).to eq(1000)
      end
    end
  end
end

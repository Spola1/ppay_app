# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TransactionDecorator do
  let(:transaction) { create :transaction }
  describe '#human_status' do
    it 'Should return Заморожена if status == frozen' do
      expect(transaction.decorate.human_status).to eq 'Заморожена'
    end
  end

  describe '#human_transaction_type' do
    it 'Should return Платеж if transaction_type == frozen' do
      expect(transaction.decorate.human_transaction_type).to eq 'Платёж'
    end
  end
end

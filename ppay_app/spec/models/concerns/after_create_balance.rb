# frozen_string_literal: true

shared_examples 'after_create_balance' do
  subject { create(described_class.to_s.underscore, initial_balance:) }
  let(:initial_balance) { 1000 }

  it 'создаст баланс' do
    expect { subject }.to change { Balance.count }.from(0).to(1)
    expect(Balance.last.amount).to eq(initial_balance)
  end
end

# frozen_string_literal: true

shared_examples 'after_create_balance' do
  subject { create(described_class.to_s.underscore) }

  it 'создаст нулевой баланс' do
    expect { subject }.to change { Balance.count }.from(0).to(1)
    expect(Balance.last.amount).to eq(0)
  end
end

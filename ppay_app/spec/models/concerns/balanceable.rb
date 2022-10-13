# frozen_string_literal: true

shared_examples 'balanceable' do
  it { is_expected.to have_one(:balance).dependent(:destroy) }
end

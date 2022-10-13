# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Balance, type: :model do
  it { is_expected.to have_many(:from_transactions).class_name('Transaction').with_foreign_key(:from_balance_id) }
  it { is_expected.to have_many(:to_transactions).class_name('Transaction').with_foreign_key(:to_balance_id) }
  it { is_expected.to belong_to(:balanceable) }
end

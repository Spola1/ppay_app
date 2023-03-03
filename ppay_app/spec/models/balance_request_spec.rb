# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BalanceRequest, type: :model do
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

  pending "add some examples to (or delete) #{__FILE__}"
end

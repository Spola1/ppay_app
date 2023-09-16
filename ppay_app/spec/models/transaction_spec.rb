# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Transaction, type: :model do
  it { is_expected.to belong_to(:from_balance).class_name('Balance').optional(true) }
  it { is_expected.to belong_to(:to_balance).class_name('Balance').optional(true) }
  it { is_expected.to belong_to(:transactionable).optional(true) }

  describe 'enums' do
    it {
      is_expected.to define_enum_for(:transaction_type)
        .with_values(main: 0,
                     ppay_commission: 1,
                     processer_commission: 2,
                     agent_commission: 3,
                     working_group_commission: 4,
                     deposit: 5,
                     withdraw: 6,
                     freeze_balance: 7)
    }
  end
end

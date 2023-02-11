require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  let(:user) { create :merchant, :with_all_kind_of_payments }

  describe 'hotlist_payments' do
    subject { helper.hotlist_payments(user) }

    it 'returns decorated deposits' do
      expect(subject.count).to eq 2
      expect([DepositDecorator, WithdrawalDecorator].include?(subject.first.class)).to be_truthy
    end
  end
end
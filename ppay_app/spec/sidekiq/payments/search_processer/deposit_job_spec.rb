# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Payments::SearchProcesser::DepositJob, type: :job do
  subject(:call) { described_class.new.perform(payment.id) }

  let!(:payment) { create(:payment, :deposit, :processer_search, payment_system: 'Sberbank') }

  let!(:advertisement1) { create(:advertisement) }
  let!(:rate_snapshot) { create(:rate_snapshot) }
  let!(:ppay) { create(:user, :ppay) }

  it 'finds an advertisement' do
    call

    expect(payment.reload.advertisement).to eq(advertisement1)
  end
end

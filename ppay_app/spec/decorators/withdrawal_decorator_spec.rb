# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WithdrawalDecorator do
  let(:payment) { create :payment, :withdrawal }

  describe '#payments_deposit_url' do
    it 'Should return url of withdrawal' do
      expect(payment.decorate.url).to eq "http://example.org/payments/withdrawals/#{payment.uuid}?signature=#{payment.signature}"
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DepositDecorator do
  let(:payment) { create :payment }
  describe '#payments_deposit_url' do
    it 'Should return url of deposit' do
      expect(payment.decorate.url).to eq "http://example.org/payments/deposits/#{payment.uuid}?signature=#{payment.signature}"
    end
  end
end

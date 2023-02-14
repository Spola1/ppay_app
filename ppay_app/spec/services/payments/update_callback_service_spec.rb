# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Payments::UpdateCallbackService, type: :service do
  describe '.call' do
    subject { described_class.call(payment) }
    let(:payment) { create :payment, :deposit, :confirming, external_order_id:, callback_url: }
    let(:callback_url) { 'http://stub-request.test' }
    let(:external_order_id) { '1234' }

    it 'makes POST request with payment\'s JSON' do
      stub_request(:post, callback_url)
        .with(
          headers: {
            'Content-Type':  'application/json',
            'Authorization': "Bearer #{payment.merchant.token}",
          },
          body: {
            data: {
              id: payment.id.to_s,
              type: 'Deposit',
              attributes: {
                uuid: payment.uuid,
                external_order_id:,
                payment_status: 'confirming'
              }
            }
          }
        )

      subject
    end
  end
end

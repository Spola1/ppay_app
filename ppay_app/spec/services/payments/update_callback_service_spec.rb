# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Payments::UpdateCallbackService, type: :service do
  describe '.call' do
    subject { described_class.call(payment) }
    let(:payment) { create :payment, :deposit, :confirming, external_order_id:, callback_url:, cancellation_reason: }
    let(:callback_url) { 'http://stub-request.test' }
    let(:external_order_id) { '1234' }
    let(:cancellation_reason) { :fraud_attempt }

    it 'makes POST request with payment\'s JSON' do
      stub_request(:post, callback_url)
        .with(
          headers: {
            'Content-Type': 'application/json',
            Authorization: "Bearer #{payment.merchant.token}"
          },
          body: {
            data: {
              id: payment.uuid,
              type: 'deposit',
              attributes: {
                uuid: payment.uuid,
                external_order_id:,
                cancellation_reason: cancellation_reason.to_s,
                payment_status: 'confirming',
                national_currency_amount: '100.0',
                initial_amount: '100.0',
                national_currency: 'RUB',
                cryptocurrency_commission_amount: nil,
                national_currency_commission_amount: nil
              }
            }
          }
        )

      subject
    end
  end
end

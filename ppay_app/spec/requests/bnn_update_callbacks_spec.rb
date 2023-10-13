require 'rails_helper'

RSpec.describe 'Api::V1::ExternalProcessing::Payments::BaseController.bnn_update_callback', type: :request do
  let!(:deposit) { create :payment, :deposit, other_processing_id: hash }
  let(:hash) { SecureRandom.uuid }

  describe 'PATCH /api/v1/external_processing/payments/bnn_update_callback' do
    before do
      stub_request(:get, %r{https://bnn-pay\.com/api/orders\?exclude_expired=true&hash=.*?&timestamp=.*})
        .to_return(
          status: 200,
          body: {
            'Success' => true,
            'Result' => {
              'Items' => [
                {
                  'Id' => 703,
                  'Hash' => hash,
                  'Amount' => 3000.0,
                  'ResultAmount' => 2910.0,
                  'AznUsdtPrice' => 1.7,
                  'Settlement' => 1711.76,
                  'Fee' => 90.0,
                  'UrlPayment' => "https://bnn-pay.com/payment/#{hash}",
                  'ExpiredAt' => '2023-10-13T09:25:00.13074',
                  'CreatedAt' => '2023-10-13T09:08:34.854176',
                  'ConfirmationDate' => '2023-10-13T09:22:00.13074',
                  'Result' => 'Success'
                }
              ],
              'CurrentPage' => 1,
              'TotalPages' => 1
            }
          }.to_json,
          headers: { 'Content-Type': 'application/json' }
        )
    end

    it 'response 200' do
      patch '/api/v1/external_processing/payments/bnn_update_callback',
            params: {
              Hash: hash,
              Status: 'Success',
              ExternalId: '201',
              Amount: 0
            }.to_json,
            headers: { 'Content-Type': 'application/json' }

      expect(response).to have_http_status(200)
    end
  end
end

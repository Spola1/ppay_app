# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'BNN deposit creation', type: :system do
  let!(:ppay) { create :user, :ppay }

  let!(:azn) { create :national_currency, name: 'AZN' }
  let!(:atb_bank) { create :payment_system, national_currency: azn, name: 'ATBBank' }
  let!(:rate_snapshot) { create :rate_snapshot, payment_system: atb_bank, value: 1.7 }
  let!(:processer) { create :processer, nickname: 'bnn', initial_balance: 9000 }
  let!(:advertisement) { create :advertisement, payment_system: atb_bank.name, national_currency: azn.name, processer: }

  let!(:merchant) { create :merchant, check_required: false, initial_balance: 9000 }
  let(:initial_national_currency_amount) { 3000 }

  let(:hash) { 'b94a044f-647d-4a8c-ae7e-2bdd33502653' }

  before do
    ENV['EXTERNAL_BNN_CALLBACK_PROTOCOL'] = 'https'
    ENV['EXTERNAL_BNN_CALLBACK_ADDRESS'] = 'example.org'

    stub_request(:get, %r{https://bnn-pay\.com/api/banks\?timestamp=.*})
      .to_return(
        status: 200,
        body: {
          'Success' => true,
          'Result' => [
            { 'Id' => 1, 'Name' => 'ATBBank' },
            { 'Id' => 2, 'Name' => 'KapitalBank' },
            { 'Id' => 3, 'Name' => 'Azericard' }
          ]
        }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    stub_request(:post, %r{https://bnn-pay\.com/api/order/create\?timestamp=.*})
      .to_return(
        status: 200,
        body: {
          'Success' => true,
          'Result' => {
            'hash' => hash,
            'payUrl' => "https://bnn-pay.com/payment/#{hash}"
          }
        }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    stub_request(:get, %r{https://bnn-pay\.com/api/order/payinfo\?hash=.*?&timestamp=.*})
      .to_return(
        status: 200,
        body: {
          'Success' => true,
          'Result' => {
            'IsActive' => true,
            'cardDetail' => {
              'Bank' => 'ATBBank',
              'Card' => '4613860208922128',
              'CancellationDate' => '2023-10-13T15:50:56.7733419Z'
            }
          }
        }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )

    stub_request(:get, %r{https://bnn-pay\.com/api/orders\?hash=.*?&timestamp=.*})
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

  scenario 'happy path' do
    post '/api/v1/external_processing/payments/deposits',
         params: {
           national_currency: azn.name,
           national_currency_amount: initial_national_currency_amount,
           external_order_id: '1234',
           locale: 'ru',
           callback_url: 'https://example.com/callback_url'
         }.to_json,
         headers: { 'Accept' => 'application/json',
                    'Content-Type' => 'application/json',
                    'Authorization' => "Bearer #{merchant.token}" }

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

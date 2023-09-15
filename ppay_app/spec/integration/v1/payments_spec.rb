# frozen_string_literal: true

require 'swagger_helper'

describe 'Payments' do
  include_context 'authorization'

  path '/api/v1/payments/{uuid}' do
    get 'Получение информации по платежу' do
      tags 'Платежи - H2H, HPP'
      produces 'application/json'
      security [bearerAuth: {}]

      description File.read(Rails.root.join('spec/support/swagger/markdown/v1/payments.md'))

      parameter name: :uuid, in: :path, type: :string

      let(:payment) do
        create :payment, :deposit, :confirming, :with_transactions, merchant:, cancellation_reason:, external_order_id:
      end
      let(:uuid) { payment.uuid }
      let(:cancellation_reason) { :fraud_attempt }
      let(:external_order_id) { '1234' }

      response '200', 'payment with uuid is present' do
        schema '$ref': '#/components/schemas/payments_show_response_body_schema'

        run_test! do |_response|
          expect(response_body['data']['attributes']['cancellation_reason']).to eq(cancellation_reason.to_s)
          expect(response_body['data']['attributes']['external_order_id']).to eq(external_order_id)
        end
      end

      response '404', 'does not found payment with invalid uuid' do
        let(:uuid) { 'invalid' }
        run_test!
      end

      response '404', 'does not found with unauthorized payment access' do
        let(:payment) { create :payment, :deposit, :confirming }
        run_test!
      end

      response '401', 'unauthorized on invalid token' do
        let(:merchant_token) { invalid_merchant_token }
        run_test!
      end
    end
  end
end

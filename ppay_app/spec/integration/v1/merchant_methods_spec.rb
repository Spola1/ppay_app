# frozen_string_literal: true

require 'swagger_helper'

describe 'Merchant Methods' do
  include_context 'merchant authorization'

  path '/api/v1/merchant_methods' do
    get 'Запрос текущих платежных методов' do
      tags 'Платежные методы'
      produces 'application/json'
      security [bearerAuth: {}]

      parameter name: :national_currency, in: :query, type: :string, description: 'National currency', required: false
      parameter name: :payment_system, in: :query, type: :string, description: 'Payment system', required: false

      response '200', 'successful response' do
        schema type: :object, required: %w[data], properties: {
          data: { type: :array, items: {
            type: :object, required: %w[id type attributes], properties: {
              id: { type: :string, example: '7' },
              type: { type: :string, example: 'merchant_method' },
              attributes: { type: :object, required: %w[
                id national_currency direction payment_system_name rate commission_percentage
              ], properties: {
                national_currency: { type: :string, example: 'RUB' },
                direction: { type: :string, example: 'Deposit' },
                payment_system_name: { type: :string, example: 'Sberbank' },
                rate: { type: :string, example: '94.12' },
                commission_percentage: { type: :string, example: '4.0' }
              } }
            }
          } }
        }

        context 'Request with valid token' do
          let(:bearer_user_token) { valid_merchant_token }

          it 'returns a successful response' do
            get '/api/v1/merchant_methods', params: { national_currency: 'RUB', payment_system: 'Sberbank' }, headers: { 'Authorization' => "Bearer #{bearer_user_token}" }
            expect(response).to have_http_status(:ok)
            expect(response_body[:data]).to have(2).items
          end
        end
      end

      response '401', 'invalid token' do
        context 'Invalid token' do
          let(:bearer_user_token) { invalid_merchant_token }

          it 'returns an empty response' do
            get '/api/v1/merchant_methods', headers: { 'Authorization' => "Bearer #{bearer_user_token}" }
            expect(response).to have_http_status(:unauthorized)
            expect(response_body).to be_blank
          end
        end
      end
    end
  end
end

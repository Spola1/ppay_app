# frozen_string_literal: true

require 'swagger_helper'

describe 'Merchant Methods' do
  include_context 'merchant authorization'

  let!(:rate_snapshot_buy) { create :rate_snapshot, :buy }
  let!(:rate_snapshot_sell) { create :rate_snapshot, :sell }

  path '/api/v1/merchant_methods' do
    post 'Запрос текущих платежных методов' do
      tags 'Платежные методы'
      produces 'application/json'
      security [bearerAuth: {}]

      # description_erb 'balance.md.erb'

      response '200', 'successful response' do
        schema type: :object, required: %w[data], properties: {
          data: { type: :array, items: {
            type: :object, required: %w[id type attributes], properties: {
              id: { type: :string, example: '7' },
              type: { type: :string, example: 'merchant_method' },
              attributes: { type: :object, required: %w[
                id national_currency direction payment_system_name rate commission_percentage
              ], properties: {
                id: { type: :string, example: '7' },
                national_currency: { type: :string, example: 'RUB' },
                direction: { type: :string, example: 'Deposit' },
                payment_system_name: { type: :string, example: 'Sberbank' },
                rate: { type: :string, example: '94.12' },
                commission_percentage: { type: :string, example: '4.0' }
              } }
            }
          } }
        }

        run_test! do
          expect(response_body[:data]).to have(2).items
        end
      end

      response '401', 'unauthorized on invalid token' do
        let(:bearer_user_token) { invalid_merchant_token }

        run_test!
      end
    end
  end
end

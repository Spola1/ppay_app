# frozen_string_literal: true

require 'swagger_helper'

describe 'Merchant Methods' do
  include_context 'merchant authorization'

  path '/api/v1/merchant_methods' do
    get 'Запрос текущих платежных методов' do
      tags 'Платежные методы'
      produces 'application/json'
      security [bearerAuth: {}]

      # description_erb 'balance.md.erb'

      shared_examples 'response 200' do
        response '200', 'bearer user sets up a valid token' do
          # schema '$ref': '#/components/schemas/balance_show_response_body_schema'

          run_test!
        end
      end

      context 'bearer user is merchant' do
        let(:bearer_user) { merchant }

        it_behaves_like 'response 200'
      end

      response '401', 'unauthorized on invalid token' do
        let(:bearer_user_token) { invalid_merchant_token }

        run_test!
      end
    end
  end
end

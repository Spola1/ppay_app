# frozen_string_literal: true

require 'swagger_helper'

describe 'Payments' do
  include_context 'authorization'

  path '/api/v1/payments/{uuid}' do
    get 'Получение информации по платежу' do
      tags 'Платежи'
      produces 'application/json'
      security [bearerAuth: {}]

      description File.read(Rails.root.join('spec/support/swagger/markdown/v1/payments.md'))

      parameter name: :uuid, in: :path, type: :string

      let(:payment) { create :payment, :deposit, :confirming }
      let(:uuid) { payment.uuid }

      response '200', 'payment with uuid is present' do
        schema '$ref': '#/components/schemas/payments_show_response_body_schema'

        run_test!
      end

      response '404', 'payment not found' do
        let(:uuid) { 'invalid' }
        run_test!
      end

      response '401', 'unauthorized' do
        let(:merchant_token) { invalid_merchant_token }
        run_test!
      end
    end
  end
end

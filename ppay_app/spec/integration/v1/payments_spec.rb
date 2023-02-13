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
        schema type: :object,
               properties: {
                 uuid: { type: :string, example: SecureRandom.uuid },
                 external_order_id: { type: :string, example: '1234' },
                 created_at: { type: :string, example: Time.zone.now.as_json },
                 type: { type: :string, example: 'Deposit' },
                 national_currency: { type: :string, example: 'RUB' },
                 national_currency_amount: { type: :number, example: 3000 },
                 cryptocurrency: { type: :string, example: 'USDT' },
                 payment_system: { type: :string, example: 'Sberbank' },
                 payment_status: { type: :string, example: 'completed' }
               },
               required: %w[uuid created_at type national_currency national_currency_amount
                            cryptocurrency payment_system payment_status]

        run_test!
      end

      response '404', 'payment not found' do
        let(:uuid) { 'invalid' }
        run_test!
      end

      response '401', 'unauthorized' do
        let(:user_token) { invalid_token }
        run_test!
      end
    end
  end
end

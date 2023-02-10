# frozen_string_literal: true

require 'swagger_helper'

describe 'Payments' do
  include_context 'authorization'

  path '/api/v1/payments/{uuid}' do
    get 'Show payment information' do
      tags 'Payments'
      produces 'application/json'
      security [bearerAuth: {}]

      # description File.read(Rails.root.join('spec/support/swagger/markdown/v1/payments.md'))

      parameter name: :uuid, in: :path, type: :string

      let!(:payments) { create_list :payment, 1 }
      let(:payment) { Payment.last }
      let(:uuid) { payment.uuid }

      response '200', 'payment with uuid is present' do
        schema type: :object,
               properties: {
                 uuid: { type: :string },
                 external_order_id: { type: :string },
                 created_at: { type: :string },
                 type: { type: :string },
                 national_currency: { type: :string },
                 national_currency_amount: { type: :number },
                 cryptocurrency: { type: :string },
                 payment_system: { type: :string },
                 payment_status: { type: :string }
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

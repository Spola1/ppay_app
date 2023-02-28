# frozen_string_literal: true

require 'swagger_helper'

describe 'Deposits' do
  include_context 'authorization'

  let!(:rate_snapshot) { create(:rate_snapshot) }

  path '/api/v1/payments/deposits' do
    post 'Создание депозита' do
      tags 'Платежи'
      consumes 'application/json'
      produces 'application/json'
      security [bearerAuth: {}]

      description File.read(Rails.root.join('spec/support/swagger/markdown/v1/payments/deposits.md'))

      parameter name: :params,
                in: :body,
                schema: { '$ref': '#/components/schemas/deposits_create_parameter_body_schema' }

      let(:payment_type) { Deposit }
      let(:unique_amount) { :integer }

      let(:params) do
        {
          national_currency: currency,
          national_currency_amount: 3000.0,
          external_order_id: '1234',
          unique_amount:,
          redirect_url: FFaker::Internet.http_url,
          callback_url: FFaker::Internet.http_url
        }
      end


      it_behaves_like 'create_payment', type: :deposit
    end
  end
end

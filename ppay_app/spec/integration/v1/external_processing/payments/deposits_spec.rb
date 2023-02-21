# frozen_string_literal: true

require 'swagger_helper'

describe 'Deposits' do
  include_context 'authorization'

  let!(:rate_snapshot) { create(:rate_snapshot) }
  let!(:adv) { create :advertisement, :deposit, payment_system: 'Tinkoff' }
  let!(:ppay) { create :user, :ppay }

  path '/api/v1/external_processing/payments/deposits' do
    post 'Создание депозита с внешним процессингом' do
      tags 'Платежи'
      consumes 'application/json'
      produces 'application/json'
      security [bearerAuth: {}]

      # description File.read(Rails.root.join('spec/support/swagger/markdown/v1/payments/deposits.md'))

      let(:payment_type) { Deposit }

      parameter name: :params,
                in: :body,
                schema: { '$ref': '#/components/schemas/external_processing_deposits_create_parameter_body_schema' }

      let(:payment_system) { 'Tinkoff' }
      let(:national_currency) { 'RUB' }
      let(:params) do
        {
          payment_system:,
          national_currency:,
          national_currency_amount: 3000.0,
          external_order_id: '1234',
          redirect_url: FFaker::Internet.http_url,
          callback_url: FFaker::Internet.http_url
        }
      end

      it_behaves_like 'create_external_processing_payment', type: :deposit
    end
  end
end

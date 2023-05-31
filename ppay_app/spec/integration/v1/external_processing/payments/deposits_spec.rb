# frozen_string_literal: true

require 'swagger_helper'

describe 'External processing deposits' do
  include_context 'authorization'
  let(:check_required) { false }

  let!(:rate_snapshot) { create(:rate_snapshot) }
  let!(:adv) { create :advertisement, :deposit, payment_system: payment_system.name, payment_link: }
  let!(:ppay) { create :user, :ppay }

  path '/api/v1/external_processing/payments/deposits' do
    post 'Создание депозита с внешним процессингом' do
      tags 'Платежи - внешний процессинг (оплата на стороне магазина)'
      consumes 'application/json'
      produces 'application/json'
      security [bearerAuth: {}]

      description File.read(Rails.root.join('spec/support/swagger/markdown/v1/external_processing/payments/' \
                                            'deposits.md'))

      let(:payment_type) { Deposit }

      parameter name: :params,
                in: :body,
                schema: { '$ref': '#/components/schemas/external_processing_deposits_create_parameter_body_schema' }

      let(:national_currency) { 'RUB' }
      let(:unique_amount) { :integer }
      let(:payment_system_name) { payment_system.name }
      let(:payment_link) { nil }
      let(:params) do
        {
          payment_system: payment_system_name,
          national_currency:,
          unique_amount:,
          external_order_id: '1234',
          national_currency_amount: '100.0',
          callback_url: FFaker::Internet.http_url
        }
      end

      it_behaves_like 'create_external_processing_payment', type: :deposit
    end
  end
end

# frozen_string_literal: true

require 'swagger_helper'

describe 'External processing withdrawals' do
  include_context 'authorization'
  let(:check_required) { false }

  let!(:rate_snapshot) { create(:rate_snapshot, :sell) }
  let!(:adv) { create :advertisement, :withdrawal, payment_system: payment_system.name }
  let!(:ppay) { create :user, :ppay }

  path '/api/v1/external_processing/payments/withdrawals' do
    post 'Создание вывода средств с внешним процессингом' do
      tags 'Платежи - внешний процессинг (оплата на стороне магазина)'
      consumes 'application/json'
      produces 'application/json'
      security [bearerAuth: {}]

      description File.read(Rails.root.join('spec/support/swagger/markdown/v1/external_processing/payments/' \
                                            'withdrawals.md'))

      let(:payment_type) { Withdrawal }

      parameter name: :params,
                in: :body,
                schema: { '$ref': '#/components/schemas/external_processing_withdrawals_create_parameter_body_schema' }

      let(:payment_system_name) { payment_system.name }
      let(:national_currency) { 'RUB' }
      let(:card_number) { '1234 5678 9012 3456' }
      let(:params) do
        {
          payment_system: payment_system_name,
          card_number:,
          national_currency:,
          national_currency_amount: 3000.0,
          external_order_id: '1234',
          callback_url: FFaker::Internet.http_url
        }
      end

      it_behaves_like 'create_external_processing_payment', type: :withdrawal
    end
  end
end

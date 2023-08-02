# frozen_string_literal: true

require 'swagger_helper'

describe 'External processing payments statuses' do
  include_context 'authorization'
  let(:check_required) { false }

  path '/api/v1/external_processing/payments/{uuid}/statuses/{event}' do
    patch 'Обновление статуса платежа с внешним процессингом' do
      tags 'Платежи - H2H (оплата на стороне магазина)'
      consumes 'application/json'
      produces 'application/json'
      security [bearerAuth: {}]

      description File.read(Rails.root.join('spec/support/swagger/markdown/v1/external_processing/payments/' \
                                            'statuses.md'))
      parameter name: :uuid, in: :path, type: :string, required: true
      parameter name: :event, in: :path, type: :string, required: true
      parameter name: :params,
                in: :body,
                schema: { '$ref': '#/components/schemas/external_processing_deposits_create_status_patameter_body_schema' }

      let(:payment) { create :payment, :deposit, :transferring, merchant:, processing_type: :external }
      let(:uuid) { payment.uuid }
      let(:event) { 'check' }
      let(:params) { { account_number: '1234' } }

      response '204', 'статус успешно обновлен' do
        %w[check cancel].each do |event|
          context "deposit #{event}" do
            let(:event) { event }
            run_test!
          end
        end

        context 'withdrawal confirm' do
          let(:payment) do
            create :payment, :withdrawal, :confirming,
                   merchant:,
                   card_number: '1111222233334444',
                   processing_type: :external
          end
          let(:event) { 'confirm' }
          run_test!
        end
      end

      response '422', 'ошибка валидации' do
        before { payment.merchant.update(account_number_required: true) }
        let(:params) { { account_number: '' } }
        let(:expected_errors) do
          [
            {
              title: 'account_number',
              detail: I18n.t('activerecord.errors.models.payment.attributes.account_number.blank'),
              code: 422
            }.stringify_keys
          ]
        end

        run_test! do |_response|
          expect(response_body['errors']).to eq(expected_errors)
        end
      end

      response '400', 'платеж был создан для HPP интеграции' do
        let(:payment) { create :payment, :deposit, :transferring, merchant:, processing_type: :internal }
        run_test!
      end

      response '400', 'данный event недоступен в текущем статусе' do
        let(:event) { 'draft' }
        run_test!
      end

      response '404', 'платеж с указанным uuid не найден' do
        let(:uuid) { 'invalid' }
        run_test!
      end

      response '404', 'платеж с указанным uuid не найден' do
        let(:payment) { create :payment, :deposit, :transferring }
        run_test!
      end

      response '401', 'неверный API-ключ' do
        let(:merchant_token) { invalid_merchant_token }
        run_test!
      end
    end
  end
end

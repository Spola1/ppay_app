# frozen_string_literal: true

require 'swagger_helper'

describe 'External processing payments statuses', document: false do
  include_context 'authorization'
  let(:check_required) { false }

  path '/api/v1/payments/{uuid}/statuses/{event}' do
    patch 'Обновление статуса платежа с внешним процессингом' do
      tags 'Платежи с внешним процессингом'
      security [bearerAuth: {}]

      # description File.read(Rails.root.join('spec/support/swagger/markdown/v1/payments.md'))

      parameter name: :uuid, in: :path, type: :string
      parameter name: :event, in: :path, type: :string

      let(:payment) { create :payment, :deposit, :transferring, merchant:, processing_type: :external }
      let(:uuid) { payment.uuid }
      let(:event) { 'check' }

      response '204', 'on allowed event' do
        %w[check cancel].each do |_event|
          context "deposit #{_event}" do
            let(:event) { _event }
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

      response '422', 'on merchant requires image' do
        let(:check_required) { true }

        let(:expected_errors) do
          [
            {
              title: 'image',
              detail: I18n.t('activerecord.errors.models.payment.attributes.image.blank'),
              code: 422
            }.stringify_keys
          ]
        end

        run_test! do |_response|
          expect(response_body['errors']).to eq(expected_errors)
        end
      end

      response '400', 'on disallowed event' do
        let(:event) { 'draft' }
        run_test!
      end

      response '400', 'on internal processing type' do
        let(:payment) { create :payment, :deposit, :transferring, merchant:, processing_type: :internal }
        run_test!
      end

      response '404', 'does not found payment with invalid uuid' do
        let(:uuid) { 'invalid' }
        run_test!
      end

      response '404', 'does not found with unauthorized payment access' do
        let(:payment) { create :payment, :deposit, :transferring }
        run_test!
      end

      response '401', 'unauthorized on invalid token' do
        let(:merchant_token) { invalid_merchant_token }
        run_test!
      end
    end
  end
end

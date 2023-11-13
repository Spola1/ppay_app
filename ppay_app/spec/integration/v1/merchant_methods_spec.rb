# frozen_string_literal: true

require 'swagger_helper'

describe 'Merchant Methods' do
  include_context 'merchant authorization'

  let!(:alter_payment_system) { create :payment_system, name: 'Tinkoff' }
  let!(:uah_national_currency) { create :national_currency, name: 'UAH' }
  let!(:uah_payment_system) { create :payment_system, name: 'MonoBank', national_currency: uah_national_currency }

  let!(:rate_snapshot_buy) { create :rate_snapshot, :buy }
  let!(:rate_snapshot_sell) { create :rate_snapshot, :sell }

  let(:national_currency_name) { national_currency.name }
  let(:payment_system_name) { payment_system.name }

  before do
    merchant.fill_in_commissions('RUB UAH')
    PaymentSystem.find_each do |payment_system|
      create(:rate_snapshot, :buy, payment_system:)
      create(:rate_snapshot, :sell, payment_system:)
    end
  end

  path '/api/v1/merchant_methods' do
    get 'Запрос текущих платежных методов' do
      tags 'Платежные методы'
      produces 'application/json'
      security [bearerAuth: {}]

      parameter name: :national_currency, getter: :national_currency_name, in: :query, type: :string,
                description: 'National currency', required: false
      parameter name: :payment_system, getter: :payment_system_name, in: :query, type: :string,
                description: 'Payment system', required: false

      response '200', 'successful response' do
        schema type: :object, required: %w[data], properties: {
          data: { type: :array, items: {
            type: :object, required: %w[id type attributes], properties: {
              id: { type: :string, example: '7' },
              type: { type: :string, example: 'merchant_method' },
              attributes: { type: :object, required: %w[
                national_currency direction payment_system rate commission_percentage
              ], properties: {
                national_currency: { type: :string, example: 'RUB' },
                direction: { type: :string, example: 'Deposit' },
                payment_system: { type: :string, example: 'Sberbank' },
                rate: { type: :string, example: '94.12' },
                commission_percentage: { type: :string, example: '4.0' }
              } }
            }
          } }
        }

        run_test! do
          expect(response_body[:data]).to have(2).items
        end

        context 'without query params' do
          let(:national_currency_name) { nil }
          let(:payment_system_name) { nil }

          run_test! do
            expect(response_body[:data]).to have(6).items
          end
        end

        context 'with only national_currency parameter' do
          let(:national_currency_name) { 'RUB' }
          let(:payment_system_name) { nil }

          run_test! do
            expect(response_body[:data]).to have(4).items
            expect(response_body[:data].map { _1[:attributes][:national_currency] }).to all(eq national_currency_name)
          end
        end

        context 'with only payment_system parameter' do
          let(:national_currency_name) { nil }
          let(:payment_system_name) { 'Tinkoff' }

          run_test! do
            expect(response_body[:data]).to have(2).items
            expect(response_body[:data].map { _1[:attributes][:payment_system] }).to all(eq payment_system_name)
          end
        end
      end

      response '401', 'unauthorized' do
        context 'Invalid token' do
          let(:bearer_user_token) { invalid_merchant_token }

          run_test!
        end
      end
    end
  end
end

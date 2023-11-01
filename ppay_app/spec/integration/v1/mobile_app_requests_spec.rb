# frozen_string_literal: true

require 'swagger_helper'

describe 'External processing payments receipts' do
  include_context 'processer authorization'

  path '/get-api-link' do
    get 'Получить ссылки для отправки пинга и сообщений' do
      tags 'Мобильное приложение'

      security [bearerAuth: {}]

      description_erb 'get_get-api-link.md.erb'

      response '200', 'успешный ответ системы' do
        produces 'application/json'

        schema type: :object,
               properties: {
                 ping_url: { type: :string, example: '/api/v1/catcher/ping' },
                 message_url: { type: :string, example: '/api/v1/simbank/requests' }
               },
               required: %i[ping_url message_url]

        context 'validates schema' do
          run_test! do
            expect(response_body[:ping_url]).to eq api_v1_catcher_ping_path
            expect(response_body[:message_url]).to eq api_v1_simbank_request_path
          end
        end
      end

      response '401', 'не авторизован' do
        context 'invalid token' do
          let(:processer_token) { invalid_processer_token }

          run_test! do
            expect(response_body).to be_blank
          end
        end
      end
    end
  end

  path '/api/v1/catcher/ping' do
    post 'Отправить пинг с информацией о клиенте' do
      tags 'Мобильное приложение'
      description_erb 'catcher/ping.md.erb'

      consumes 'application/json'
      security [bearerAuth: {}]

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          application: {
            type: :object,
            properties: {
              id: { type: :string, example: SecureRandom.uuid },
              version: { type: :string, example: '1.33.7' }
            },
            required: %i[id version]
          },
          device: {
            type: :object,
            properties: {
              ip: { type: :string, example: '1.3.3.7' },
              model: { type: :string, example: 'TopForItsMoney 13X' }
            },
            required: %i[ip model]
          }
        },
        required: %i[application device]
      }

      let(:params) do
        {
          application: {
            id: SecureRandom.uuid,
            version: '1.0.0'
          },
          device: {
            ip: FFaker::Internet.ip_v4_address,
            model: 'топ за свои деньги'
          }
        }
      end

      response '201', 'запись с клиентской информацией создана' do
        it 'creates a mobile app request record with actual data' do |example|
          expect { submit_request(example.metadata) }.to change {
            MobileAppRequest.count
          }.from(0).to(1)

          record = MobileAppRequest.first
          expect(record.application_id).to eq params[:application][:id]
          expect(record.application_version).to eq params[:application][:version]
          expect(record.device_ip).to eq params[:device][:ip]
          expect(record.device_model).to eq params[:device][:model]
          expect(record.api_key).to eq processer_token
          expect(record.user).to eq processer
        end

        context 'with invalid token' do
          let(:processer_token) { invalid_processer_token }

          it 'creates a mobile app request record with actual data' do |example|
            expect { submit_request(example.metadata) }.to change {
              MobileAppRequest.count
            }.from(0).to(1)

            record = MobileAppRequest.first
            expect(record.application_id).to eq params[:application][:id]
            expect(record.application_version).to eq params[:application][:version]
            expect(record.device_ip).to eq params[:device][:ip]
            expect(record.device_model).to eq params[:device][:model]
            expect(record.api_key).to eq processer_token
            expect(record.user).to be_nil
          end
        end
      end
    end
  end
end

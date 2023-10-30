# frozen_string_literal: true

require 'swagger_helper'

describe 'MobileAppRequests' do
  include_context 'authorization'

  let(:save_application_info) do
    MobileAppRequest.create(
      application_id: 'some_id',
      version: '1.0',
      current_device_ip: '127.0.0.1',
      device_model: 'iPhone'
    )
  end

  path '/get-api-link' do
    get 'Get links' do
      tags 'MobileAppRequests'
      produces 'application/json'
      security [bearerAuth: {}]

      description 'Get ping and message URLs'

      response '200', 'Links' do
        schema '$ref': '#/components/schemas/t_mobile_app_requests_api_link_response_body_schema'

        before do
          ENV['MOBILE_APP_PING_LINK'] = 'test_ping_link'
          ENV['MOBILE_APP_SIMBANK_LINK'] = 'test_simbank_link'
        end

        run_test! do |_response|
          expect(response_body['ping_url']).to eq('test_ping_link')
          expect(response_body['message_url']).to eq('test_simbank_link')
        end

        after do
          ENV['MOBILE_APP_PING_LINK'] = nil
          ENV['MOBILE_APP_SIMBANK_LINK'] = nil
        end
      end
    end

    post 'Get links' do
      tags 'MobileAppRequests'
      produces 'application/json'
      security [bearerAuth: {}]

      description 'Create application'

      response '200', 'Links' do
        schema '$ref': '#/components/schemas/post_mobile_app_requests_api_link_response_body_schema'

        before do
          ENV['MOBILE_APP_PING_LINK'] = 'test_ping_link'
          ENV['MOBILE_APP_SIMBANK_LINK'] = 'test_simbank_link'
        end

        before do
          post '/api/v1/catcher/ping', params: {
            application_id: 'app_id',
            version: '1.0'
          }
        end

        run_test! do |_response|
          expect(response_body['message']).to eq('Information saved successfully')
          expect { save_application_info }.to change(MobileAppRequest, :count).by(1)
        end
      end
    end
  end

  path '/api/v1/catcher/ping' do
    post 'Receive ping' do
      tags 'MobileAppRequests'
      produces 'application/json'
      security [bearerAuth: {}]

      description 'Receive ping'

      response '200', 'Pings' do
        schema '$ref': '#/components/schemas/post_mobile_app_requests_receive_ping_response_body_schema'

        before do
          post '/api/v1/catcher/ping', params: {
            application_id: 'app_id',
            version: '1.0',
            current_device_ip: '127.0.0.1',
            device_model: 'iPhone'
          }
        end

        run_test! do |_response|
          expect(response_body['message']).to eq('Information saved successfully')
          expect { save_application_info }.to change(MobileAppRequest, :count).by(1)
        end
      end
    end
  end
end

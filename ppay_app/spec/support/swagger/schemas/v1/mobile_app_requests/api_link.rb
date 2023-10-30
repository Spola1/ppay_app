# frozen_string_literal: true

module Swagger
  module Schemas
    module V1
      module MobileAppRequests
        module ApiLink
          extend self

          def schemas
            [
              get_api_link_response_body_schema,
              receive_ping_response_body_schema,
              post_get_api_link_response_body_schema
            ].inject(:merge)
          end

          private

          def get_api_link_response_body_schema
            {
              t_mobile_app_requests_api_link_response_body_schema: {
                type: :object,
                properties: {
                  ping_url: { type: :string, example: 'test_ping_link' },
                  message_url: { type: :string, example: 'test_simbank_link' }
                },
                required: %w[ping_url message_url]
              }
            }
          end

          def post_get_api_link_response_body_schema
            {
              post_mobile_app_requests_api_link_response_body_schema: {
                type: :object,
                properties: {
                  message: { type: :string, example: 'Information saved successfully' }
                },
                required: %w[message]
              }
            }
          end

          def receive_ping_response_body_schema
            {
              post_mobile_app_requests_receive_ping_response_body_schema: {
                type: :object,
                properties: {
                  message: { type: :string, example: 'Information saved successfully' }
                },
                required: %w[message]
              }
            }
          end
        end
      end
    end
  end
end

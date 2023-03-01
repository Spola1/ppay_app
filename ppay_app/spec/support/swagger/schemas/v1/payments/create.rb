# frozen_string_literal: true

module Swagger
  module Schemas
    module V1
      module Payments
        module Create
          extend self

          def schemas
            [
              create_parameter_body_schema,
              create_response_body_schema
            ].inject(:merge)
          end

          private

          def create_parameter_body_schema
            {
              deposits_create_parameter_body_schema: {
                type: :object,
                properties: {
                  national_currency: { type: :string, example: 'RUB' },
                  national_currency_amount: { type: :number, example: 3000.0 },
                  external_order_id: { type: :string, example: '1234' },
                  unique_amount: { type: :string, example: 'integer' },
                  redirect_url: { type: :string, example: 'https://example.com/redirect_url' },
                  callback_url: { type: :string, example: 'https://example.com/callback_url' }
                }
              },
              withdrawals_create_parameter_body_schema: {
                type: :object,
                properties: {
                  national_currency: { type: :string, example: 'RUB' },
                  national_currency_amount: { type: :number, example: 3000.0 },
                  external_order_id: { type: :string, example: '1234' },
                  redirect_url: { type: :string, example: 'https://example.com/redirect_url' },
                  callback_url: { type: :string, example: 'https://example.com/callback_url' }
                }
              }
            }
          end

          def create_response_body_schema
            {
              payments_create_response_body_schema: {
                type: :object,
                properties: {
                  data: {
                    type: :object,
                    properties: {
                      id: { type: :string },
                      type: { type: :string },
                      attributes: {
                        type: :object,
                        properties: {
                          uuid: { type: :string },
                          url: { type: :string }
                        },
                        required: %w[uuid url]
                      }
                    },
                    required: %w[id type attributes]
                  }
                },
                required: %w[data]
              }
            }
          end
        end
      end
    end
  end
end

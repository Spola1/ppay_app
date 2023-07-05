# frozen_string_literal: true

module Swagger
  module Schemas
    module V1
      module Balance
        module Show
          extend self

          def schemas
            show_response_body_schema
          end

          private

          def show_response_body_schema
            {
              balance_show_response_body_schema: {
                type: :object,
                properties: {
                  data: {
                    type: :object,
                    properties: {
                      id: { type: :string, example: '123' },
                      type: { type: :string, example: 'Balance' },
                      attributes: {
                        type: :object,
                        properties: {
                          id: { type: :string, example: '123' },
                          amount: { type: :string, example: '99.99' },
                          currency: { type: :string, example: 'USDT' }
                        },
                        required: %w[id amount currency]
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

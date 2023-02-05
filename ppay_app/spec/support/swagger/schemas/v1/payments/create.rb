# frozen_string_literal: true

module Swagger
  module Schemas
    module V1
      module Payments
        module Create
          extend self

          def schemas
            create_parameter_body_schema
          end

          private

          def create_parameter_body_schema
            {
              payments_create_parameter_body_schema: {
                type: :object,
                properties: {
                  national_currency: { type: :string, example: 'RUB' },
                  national_currency_amount: { type: :number, example: 3000.0 },
                  external_order_id: { type: :string, example: '1234' }
                }
              }
            }
          end
        end
      end
    end
  end
end

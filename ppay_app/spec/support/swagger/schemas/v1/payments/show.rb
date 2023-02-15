# frozen_string_literal: true

module Swagger
  module Schemas
    module V1
      module Payments
        module Show
          extend self

          def schemas
            show_response_body_schema
          end

          private

          def show_response_body_schema
            {
              payments_show_response_body_schema: {
                type: :object,
                properties: {
                  uuid: { type: :string, example: SecureRandom.uuid },
                  external_order_id: { type: :string, example: '1234' },
                  created_at: { type: :string, example: Time.zone.now.as_json },
                  type: { type: :string, example: 'Deposit' },
                  national_currency: { type: :string, example: 'RUB' },
                  national_currency_amount: { type: :number, example: 3000.0 },
                  cryptocurrency: { type: :string, example: 'USDT' },
                  payment_system: { type: :string, example: 'Sberbank' },
                  payment_status: { type: :string, example: 'completed' }
                },
                required: %w[uuid created_at type national_currency national_currency_amount
                             cryptocurrency payment_system payment_status]
              }
            }
          end
        end
      end
    end
  end
end

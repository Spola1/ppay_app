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
              payments_show_response_body_schema: { type: :object, required: %w[data], properties: {
                data: { type: :object, required: %w[id type attributes], properties: {
                  id: { type: :string },
                  type: { type: :string },
                  attributes: { type: :object, required: %w[
                    uuid created_at national_currency national_currency_amount
                    cryptocurrency payment_system payment_status rate commission_percentage
                  ], properties: {
                    uuid: { type: :string, example: SecureRandom.uuid },
                    external_order_id: { type: :string, example: '1234' },
                    created_at: { type: :string, example: Time.zone.now.as_json },
                    national_currency: { type: :string, example: 'RUB' },
                    national_currency_amount: { type: :string, example: '3000.0' },
                    initial_amount: { type: :string, example: '3000.0' },
                    cryptocurrency: { type: :string, example: 'USDT' },
                    payment_system: { type: :string, example: 'Sberbank' },
                    payment_status: { type: :string, example: 'cancelled' },
                    cancellation_reason: { type: :string, example: 'fraud_attempt' },
                    cryptocurrency_commission_amount: { type: :number, nullable: true, example: 9.99 },
                    national_currency_commission_amount: { type: :number, nullable: true, example: 99.99 },
                    rate: { type: :string, nullable: true, example: '94.12' },
                    commission_percentage: { type: :string, example: '4.0' }
                  } }
                } }
              } }
            }
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Swagger
  module Schemas
    module V1
      module ExternalProcessing
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
                external_processing_deposits_create_parameter_body_schema: {
                  type: :object,
                  properties: {
                    payment_system: { type: :string, example: 'Sberbank' },
                    national_currency: { type: :string, example: 'RUB' },
                    national_currency_amount: { type: :number, example: 3000.0 },
                    external_order_id: { type: :string, example: '1234' },
                    redirect_url: { type: :string, example: 'https://example.com/redirect_url' },
                    callback_url: { type: :string, example: 'https://example.com/callback_url' }
                  }
                },
                external_processing_withdrawals_create_parameter_body_schema: {
                  type: :object,
                  properties: {
                    payment_system: { type: :string, example: 'Sberbank' },
                    card_number: { type: :string, example: '1234 5678 9012 3456' },
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
                external_processing_deposits_create_response_body_schema: {
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
                            card_number: { type: :string },
                            expiration_time: { type: :string }
                          },
                          required: %w[uuid card_number expiration_time]
                        }
                      },
                      required: %w[id type attributes]
                    },
                  },
                  required: %w[data]
                },
                external_processing_withdrawals_create_response_body_schema: {
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
                            uuid: { type: :string }
                          },
                          required: %w[uuid]
                        }
                      },
                      required: %w[id type attributes]
                    },
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
end

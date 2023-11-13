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
                create_response_body_schema,
                create_status_parameter_body_schema
              ].inject(:merge)
            end

            private

            def create_status_parameter_body_schema
              {
                external_processing_deposits_create_status_patameter_body_schema: {
                  type: :object,
                  properties: {
                    account_number: { type: :string, example: '1234' }
                  }
                }
              }
            end

            def create_parameter_body_schema
              {
                external_processing_deposits_create_parameter_body_schema: {
                  type: :object,
                  properties: {
                    payment_system: { type: :string, example: 'Sberbank' },
                    national_currency: { type: :string, example: 'RUB' },
                    national_currency_amount: { type: :number, example: 3000.0 },
                    external_order_id: { type: :string, example: '1234' },
                    # unique_amount: { type: :string, example: 'integer' },
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
                    callback_url: { type: :string, example: 'https://example.com/callback_url' }
                  }
                }
              }
            end

            def create_response_body_schema
              {
                external_processing_deposits_create_response_body_schema: {
                  type: :object, required: %w[data], properties: {
                    data: { type: :object, required: %w[id type attributes], properties: {
                      id: { type: :string },
                      type: { type: :string },
                      attributes: { type: :object, required: %w[
                        uuid card_number expiration_time national_currency national_currency_amount
                        initial_amount rate commission_percentage
                      ], properties: {
                        uuid: { type: :string },
                        card_number: { type: :string },
                        expiration_time: { type: :string },
                        national_currency: { type: :string },
                        national_currency_amount: { type: :string },
                        payment_system: { type: :string, example: 'Sberbank' },
                        initial_amount: { type: :string },
                        payment_link: { type: :string, nullable: true },
                        payment_link_qr_code_url: { type: :string, nullable: true },
                        cryptocurrency_commission_amount: { type: :number, example: 10.0 },
                        national_currency_commission_amount: { type: :number, example: 100.0 },
                        card_owner_name: { type: :string, example: 'John Doe' },
                        sbp_phone_number: { type: :string, example: '+1234567890' },
                        rate: { type: :string, example: '94.12' },
                        commission_percentage: { type: :string, example: '4.0' }
                      } }
                    } }
                  }
                },
                external_processing_withdrawals_create_response_body_schema: {
                  type: :object, required: %w[data], properties: {
                    data: { type: :object, required: %w[id type attributes], properties: {
                      id: { type: :string },
                      type: { type: :string },
                      attributes: { type: :object, required: %w[
                        uuid national_currency national_currency_amount initial_amount rate commission_percentage
                      ], properties: {
                        uuid: { type: :string },
                        expiration_time: { type: :string },
                        national_currency: { type: :string },
                        national_currency_amount: { type: :string },
                        initial_amount: { type: :string },
                        cryptocurrency_commission_amount: { type: :number, example: 10.0 },
                        national_currency_commission_amount: { type: :number, example: 100.0 },
                        rate: { type: :string, example: '94.12' },
                        commission_percentage: { type: :string, example: '4.0' }
                      } }
                    } }
                  }
                }
              }
            end
          end
        end
      end
    end
  end
end

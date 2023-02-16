# frozen_string_literal: true

module Api
  module V1
    module ExternalProcessing
      module Payments
        class BaseController < ActionController::API
          include ApiKeyAuthenticatable
          include Resourceable

          prepend_before_action :authenticate_with_api_key!

          def create
            @object = current_bearer.becomes(Merchant)
                        .public_send(model_class_plural.to_s)
                        .new(permitted_params.merge(processing_type: :external))

            if @object.save
              render json: serialized_object, status: :created
            else
              render_object_errors(@object)
            end
          end

          private

          def permitted_params
            params.permit(
              :payment_system, :national_currency_amount, :national_currency,
              :external_order_id, :redirect_url, :callback_url
            )
          end

          def serializer
            "Api::V1::Payments::Create::#{model_class}Serializer".classify.constantize
          end
        end
      end
    end
  end
end

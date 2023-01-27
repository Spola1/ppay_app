# frozen_string_literal: true

module Api
  module V1
    class PaymentsController < ActionController::API
      include ApiKeyAuthenticatable
      include Resourceable

      prepend_before_action :authenticate_with_api_key!

      def create
        @object = current_bearer.becomes(Merchant).public_send("#{ model_class_plural }").new(permitted_params)

        if @object.save
          render json: serialized_object, status: :created
        else
          render_object_errors(@object)
        end
      end

      private

      def permitted_params
        params.permit(:national_currency_amount, :national_currency, :external_order_id)
      end

      def serializer
        "Api::V1::Payments::#{ model_class }Serializer".classify.constantize
      end
    end
  end
end

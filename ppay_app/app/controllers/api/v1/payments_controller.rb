# frozen_string_literal: true

module Api
  module V1
    class PaymentsController < ActionController::API
      include ApiKeyAuthenticatable
      include Resourceable

      prepend_before_action :authenticate_with_api_key!

      respond_to :json
      rescue_from(ActiveRecord::RecordNotFound) { head :not_found }
      rescue_from(ActionController::BadRequest) { head :bad_request }

      def show
        render json: serializer.new(payment).serializable_hash
      end

      private

      def payment
        @payment ||= current_bearer.becomes(Merchant).payments.find_by! uuid: params[:uuid]
      end

      def serializer
        "Api::V1::Payments::Show::#{payment.type}Serializer".constantize
      end
    end
  end
end

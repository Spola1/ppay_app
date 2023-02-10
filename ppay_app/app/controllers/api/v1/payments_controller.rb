# frozen_string_literal: true

module Api
  module V1
    class PaymentsController < ActionController::API
      include ApiKeyAuthenticatable

      prepend_before_action :authenticate_with_api_key!

      respond_to :json

      def show
        return head :not_found unless payment.present?

        respond_with payment
      end

      private

      def payment
        @payment ||= Payment.find_by uuid:
      end

      def uuid
        params.permit(:uuid)[:uuid]
      end
    end
  end
end

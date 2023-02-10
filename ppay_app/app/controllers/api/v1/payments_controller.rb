# frozen_string_literal: true

module Api
  module V1
    class PaymentsController < ActionController::API
      include ApiKeyAuthenticatable

      prepend_before_action :authenticate_with_api_key!

      respond_to :json

      def show
        respond_with Payment.find_by uuid:
      end

      private

      def uuid
        params.permit(:uuid)[:uuid]
      end
    end
  end
end

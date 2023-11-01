# frozen_string_literal: true

module Api
  module V1
    class MobileAppRequestsController < ActionController::API
      include ApiKeyAuthenticatable

      prepend_before_action :authenticate_with_api_key

      def api_link
        return(head :unauthorized) unless current_bearer

        render json: {
          ping_url: api_v1_catcher_ping_path,
          message_url: api_v1_simbank_request_path
        }
      end

      def ping
        create_mobile_app_request

        head :created
      end

      private

      def create_mobile_app_request
        MobileAppRequest.create!(
          application_id: params.dig(:application, :id),
          application_version: params.dig(:application, :version),
          device_ip: params.dig(:device, :ip),
          device_model: params.dig(:device, :model),
          api_key: current_http_token,
          user: current_bearer
        )
      end
    end
  end
end

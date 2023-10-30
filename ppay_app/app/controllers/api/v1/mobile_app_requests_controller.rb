# frozen_string_literal: true

module Api
  module V1
    class MobileAppRequestsController < ApplicationController
      skip_before_action :verify_authenticity_token

      def api_link
        if request.get?
          render_links
        elsif request.post?
          save_application_info
        else
          render_error('Invalid request method')
        end
      end

      private

      def render_links
        ping_url = ENV.fetch('MOBILE_APP_PING_LINK')
        message_url = ENV.fetch('MOBILE_APP_SIMBANK_LINK')
        render json: { ping_url:, message_url: }, status: :ok
      end

      def save_application_info
        MobileAppRequest.create(
          application_id: params[:application_id],
          version: params[:version],
          current_device_ip: params[:current_device_ip],
          device_model: params[:device_model]
        )
        render json: { message: 'Application information saved successfully' }, status: :ok
      end

      def render_error(message)
        render json: { error: message }, status: :bad_request
      end
    end
  end
end

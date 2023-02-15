# frozen_string_literal: true

module Api
  module V1
    class PaymentsController < ActionController::API
      include ApiKeyAuthenticatable

      prepend_before_action :authenticate_with_api_key!

      respond_to :json
      rescue_from(ActiveRecord::RecordNotFound) { head :not_found }

      def show
        respond_with Payment.find_by! uuid: params[:uuid]
      end
    end
  end
end

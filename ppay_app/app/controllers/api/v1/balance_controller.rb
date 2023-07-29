# frozen_string_literal: true

module Api
  module V1
    class BalanceController < ActionController::API
      include ApiKeyAuthenticatable

      prepend_before_action :authenticate_with_api_key!

      def show
        render json: BalanceSerializer.new(balance).serializable_hash
      end

      private

      def balance
        @balance ||= current_bearer.balance
      end
    end
  end
end

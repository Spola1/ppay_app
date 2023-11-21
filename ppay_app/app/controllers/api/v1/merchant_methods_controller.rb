module Api
  module V1
    class MerchantMethodsController < ActionController::API
      include ApiKeyAuthenticatable

      prepend_before_action :authenticate_with_api_key!

      def index
        render json: MerchantMethodSerializer.new(objects)
      end

      private

      def objects
        current_bearer
          .merchant_methods
          .includes(:commissions, payment_system: %i[latest_buy_rate_snapshot
                                                     latest_sell_rate_snapshot
                                                     national_currency])
          .filter_by(filtering_params)
          .decorate
      end

      def filtering_params
        params.permit(:payment_system, :national_currency)
      end
    end
  end
end

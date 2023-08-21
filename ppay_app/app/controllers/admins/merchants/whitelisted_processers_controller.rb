# frozen_string_literal: true

module Admins
  module Merchants
    class WhitelistedProcessersController < BaseController
      skip_before_action :find_merchant, only: :update

      def show; end

      def update
        merchant = Merchant.find_by_id(params[:merchant_id])
        merchant.update(merchant_params)

        redirect_back fallback_location: merchant_whitelisted_processers_path(merchant)
      end

      private

      def prepare_whitelisted_processers(merchant_params)
        merchant_params[:whitelisted_processers] =
          if merchant_params[:whitelisted_processers]&.keys
            Processer.find(merchant_params[:whitelisted_processers].keys)
          else
            []
          end
      end

      def merchant_params
        params.require(:merchant).permit(:only_whitelisted_processers, whitelisted_processers: {})
              .tap { prepare_whitelisted_processers(_1) }
      end

      def find_merchant
        @merchant = Merchant.includes(:whitelisted_processers).find_by_id(params[:merchant_id]).decorate
      end
    end
  end
end

# frozen_string_literal: true

module Admins
  module Merchants
    class BaseController < Staff::BaseController
      before_action :find_merchant

      layout 'admins/merchants/edit'

      private

      def find_merchant
        @merchant = Merchant.find_by_id(params[:merchant_id]).decorate
      end
    end
  end
end

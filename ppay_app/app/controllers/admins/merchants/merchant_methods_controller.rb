# frozen_string_literal: true

module Admins
  module Merchants
    class MerchantMethodsController < BaseController
      def create
        if params[:add_methods]
          @merchant.fill_in_commissions(keywords)
        elsif params[:delete_methods]
          @merchant.destroy_merchant_methods(keywords)
        end

        redirect_to merchant_settings_path(@merchant)
      end

      def destroy
        if @merchant.merchant_methods.destroy(params[:id])
          redirect_to merchant_settings_path(@merchant), notice: 'Метод успешно удалён', status: :see_other
        else
          redirect_to merchant_settings_path(@merchant), alert: 'Ошибка удаления метода', status: :see_other
        end
      end

      private

      def keywords
        return if params[:keywords].empty?

        params[:keywords]
      end
    end
  end
end

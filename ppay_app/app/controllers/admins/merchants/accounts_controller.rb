# frozen_string_literal: true

module Admins
  module Merchants
    class AccountsController < Staff::BaseController
      before_action :find_merchant

      layout 'admins/merchants/edit'

      def index; end

      def update
        @merchant.email = merchant_params[:email]
        @merchant.password = merchant_params[:password] if merchant_params[:password].present?

        if @merchant.save
          redirect_to merchant_account_path(@merchant), notice: 'Запись успешно обновлена'
        else
          redirect_to merchant_account_path(@merchant), alert: 'Ошибка обновления'
        end
      end

      private

      def find_merchant
        @merchant = Merchant.find_by_id(params[:merchant_id]).decorate
      end

      def merchant_params
        params.require(:merchant).permit(:email, :password)
      end
    end
  end
end

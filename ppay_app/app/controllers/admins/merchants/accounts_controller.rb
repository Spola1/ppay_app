# frozen_string_literal: true

module Admins
  module Merchants
    class AccountsController < BaseController
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

      def merchant_params
        params.require(:merchant).permit(:email, :password)
      end
    end
  end
end

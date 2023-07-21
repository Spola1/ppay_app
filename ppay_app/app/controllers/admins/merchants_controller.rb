# frozen_string_literal: true

module Admins
  class MerchantsController < Staff::BaseController
    def index
      set_all_merchants
    end

    def new
      @merchant = Merchant.new
    end

    def create
      @merchant = Merchant.new(merchant_params)

      if @merchant.save
        redirect_to merchant_settings_path(@merchant)
      else
        render 'new'
      end
    end

    private

    def set_all_merchants
      @pagy, @merchants = pagy(Merchant.all)
      @merchants = @merchants.order(created_at: :desc).decorate
    end

    def find_merchant
      @merchant = Merchant.find_by_id(params[:id]).decorate
    end

    def merchant_params
      params.require(:merchant)
            .permit(:email, :password, :password_confirmation)
            .merge(type: :Merchant)
    end
  end
end

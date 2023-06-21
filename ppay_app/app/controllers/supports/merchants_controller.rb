# frozen_string_literal: true

module Supports
  class MerchantsController < Staff::BaseController
    before_action :find_merchant, only: %i[update settings update_settings account]
    layout 'supports/merchants/edit', only: %i[settings account]

    def index
      set_all_merchants
    end

    def new
      @merchant = Merchant.new
    end

    def create
      @merchant = Merchant.new(merchant_params)

      if @merchant.save
        redirect_to merchant_path(@merchant)
      else
        render 'new'
      end
    end

    def settings
      set_commissions
    end

    def update_settings
      @merchant.update(settings_params)

      grouped_commission = commissions_params[:commissions]
                           .to_h.map { { id: _1, commission: _2 } }
                           .index_by { _1[:id] }

      Commission.update(grouped_commission.keys, grouped_commission.values)

      redirect_back fallback_location: settings_merchant_path(@merchant)
    end

    def account; end

    def update
      @merchant.update(merchant_params)

      render :account
    end

    private

    def set_all_merchants
      @pagy, @merchants = pagy(Merchant.all)
      @merchants = @merchants.decorate
    end

    def find_merchant
      @merchant = Merchant.find_by_id(params[:id]).decorate
    end

    def set_commissions
      @commissions =
        @merchant.commissions
                 .joins(:merchant_method)
                 .joins(merchant_method: :payment_way)
                 .joins(merchant_method: { payment_way: :payment_system })
                 .joins(merchant_method: { payment_way: :national_currency })
                 .select(
                   'commissions.id, commissions.commission_type, commissions.commission, ' +
                   'commissions.merchant_method_id AS merchant_method_id, merchant_methods.direction, ' +
                   'payment_systems.name AS payment_system_name, national_currencies.name AS national_currency_name'
                 )
                 .order(commission_type: :asc, 'payment_ways.payment_system_id': :asc,
                        'payment_ways.national_currency_id': :asc, direction: :asc)
                 .group_by(&:merchant_method_id)
    end

    def merchant_params
      params.require(:merchant)
            .permit(:email, :password, :password_confirmation)
            .merge(type: :Merchant)
    end

    def settings_params
      params.require(:merchant).permit(:nickname)
    end

    def commissions_params
      params.require(:merchant).permit(commissions: {})
    end
  end
end

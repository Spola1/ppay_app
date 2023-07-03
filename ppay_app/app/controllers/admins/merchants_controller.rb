# frozen_string_literal: true

module Admins
  class MerchantsController < Staff::BaseController
    before_action :find_merchant, only: %i[settings update_settings account update_account]
    layout 'admins/merchants/edit', only: %i[settings account]

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
      @merchant.update(settings_params.except(:commissions))

      grouped_commission = settings_params[:commissions]
                           .to_h.map { { id: _1, commission: _2 } }
                           .index_by { _1[:id] }

      Commission.update(grouped_commission.keys, grouped_commission.values)

      redirect_back fallback_location: settings_merchant_path(@merchant)
    end

    def account; end

    def update_account
      @merchant.email = merchant_params[:email]
      @merchant.password = merchant_params[:password] if merchant_params[:password].present?

      if @merchant.save
        redirect_to account_merchant_path(@merchant), notice: 'Запись успешно обновлена'
      else
        redirect_to account_merchant_path(@merchant), alert: 'Ошибка обновления'
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

    def set_commissions
      @commissions =
        @merchant.commissions
                 .joins(merchant_method: { payment_system: :national_currency })
                 .select(
                   'commissions.id, commissions.commission_type, commissions.commission, ' \
                   'commissions.merchant_method_id AS merchant_method_id, merchant_methods.direction, ' \
                   'payment_systems.name AS payment_system_name, national_currencies.name AS national_currency_name'
                 )
                 .order(commission_type: :asc, 'payment_systems.id': :asc,
                        'payment_systems.national_currency_id': :asc, direction: :asc)
                 .group_by(&:merchant_method_id)
    end

    def merchant_params
      params.require(:merchant)
            .permit(:email, :password, :password_confirmation)
            .merge(type: :Merchant)
    end

    def settings_params
      params.require(:merchant)
            .permit(:nickname, :name, :check_required, :unique_amount, commissions: {})
    end
  end
end

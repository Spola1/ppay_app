# frozen_string_literal: true

module Admins
  class PaymentSystemsController < Staff::BaseController
    def index
      @payment_systems = PaymentSystem.includes(national_currency: :payment_systems)
    end

    def update
      PaymentSystem.upsert_all(payment_systems_params[:payment_systems])
      redirect_back fallback_location: payment_systems_path
    end

    private

    def payment_systems_params
      params.require(:payment_systems)
            .permit(payment_systems: %i[id binance_name payment_system_copy_id national_currency_id
                                        ad_position_deposit ad_position_withdrawal
                                        trans_amount_deposit trans_amount_withdrawal])
    end
  end
end

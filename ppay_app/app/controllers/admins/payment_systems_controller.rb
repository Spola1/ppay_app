# frozen_string_literal: true

module Admins
  class PaymentSystemsController < Staff::BaseController
    def index
      @payment_systems = PaymentSystem.includes(national_currency: :payment_systems).order(id: :asc)
    end

    def update
      PaymentSystem.upsert_all(payment_systems_params[:payment_systems])
      redirect_back fallback_location: payment_systems_path
    end

    private

    def payment_systems_params
      params.require(:payment_systems)
            .permit(payment_systems: %i[id exchange_portal_id exchange_name payment_system_copy_id national_currency_id
                                        adv_position_deposit adv_position_withdrawal
                                        trans_amount_deposit trans_amount_withdrawal
                                        extra_percent_deposit extra_percent_withdrawal])
    end
  end
end

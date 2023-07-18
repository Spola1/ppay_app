# frozen_string_literal: true

module Admins
  class NationalCurrenciesController < Staff::BaseController
    def index
      @national_currencies = NationalCurrency.includes(:payment_systems).order(id: :asc)
    end

    def update
      NationalCurrency.upsert_all(national_currencies_params[:national_currencies])
      redirect_back fallback_location: national_currencies_path
    end

    private

    def national_currencies_params
      params.require(:national_currencies)
            .permit(national_currencies:
                    %i[id default_payment_system_id
                       adv_position_deposit adv_position_withdrawal])
    end
  end
end

# frozen_string_literal: true

module Api
  module V1
    module Payments
      class DepositsController < BaseController
        private

        def permitted_params
          params.permit(
            :national_currency_amount, :national_currency, :external_order_id,
            :unique_amount, :redirect_url, :callback_url, :locale, :form_customization_id
          )
        end
      end
    end
  end
end

# frozen_string_literal: true

module Api
  module V1
    module ExternalProcessing
      module Payments
        class DepositsController < BaseController
          private

          def search_params
            permitted_params.slice(:payment_system)
          end

          def permitted_params
            params.require(:deposit).permit(
              :payment_system, :national_currency_amount, :national_currency, :external_order_id, :unique_amount,
              :callback_url, :advertisement_id
            )
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Api
  module V1
    module ExternalProcessing
      module Payments
        class WithdrawalsController < BaseController
          private

          def search_params
            permitted_params.slice(:payment_system, :card_number)
          end

          def permitted_params
            params.require(:withdrawal).permit(
              :payment_system, :card_number, :national_currency_amount, :national_currency,
              :external_order_id, :redirect_url, :callback_url
            )
          end
        end
      end
    end
  end
end

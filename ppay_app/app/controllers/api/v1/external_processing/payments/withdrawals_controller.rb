# frozen_string_literal: true

module Api
  module V1
    module ExternalProcessing
      module Payments
        class WithdrawalsController < BaseController
          private

          def permitted_params
            params.permit(
              :payment_system, :card_number, :national_currency_amount, :national_currency,
              :external_order_id, :redirect_url, :callback_url
            )
          end
        end
      end
    end
  end
end

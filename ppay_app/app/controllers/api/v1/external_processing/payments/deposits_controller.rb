# frozen_string_literal: true

module Api
  module V1
    module ExternalProcessing
      module Payments
        class DepositsController < BaseController
          def create
            @object = current_bearer.becomes(Merchant).deposits
                        .new(permitted_params.merge(processing_type: :external))

            if @object.save
              @object.inline_search!(search_params)

              render json: serialized_object, status: :created
            else
              render_object_errors(@object)
            end
          end

          private

          def search_params
            permitted_params.slice(:payment_system)
          end

          def permitted_params
            params.require(model_class.underscore.to_sym).permit(
              :payment_system, :national_currency_amount, :national_currency,
              :external_order_id, :redirect_url, :callback_url
            )
          end

          def serializer
            Api::V1::ExternalProcessing::Payments::Create::DepositSerializer
          end
        end
      end
    end
  end
end

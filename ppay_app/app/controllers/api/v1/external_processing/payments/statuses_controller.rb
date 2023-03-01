# frozen_string_literal: true

module Api
  module V1
    module ExternalProcessing
      module Payments
        class StatusesController < Api::V1::PaymentsController
          def update
            raise ActionController::BadRequest unless payment.external?

            render_object_errors(payment) unless payment.public_send("#{allowed_event}!")
          end

          private

          def deposit_allowed_events
            %i[check cancel]
          end

          def withdrawal_allowed_events
            %i[confirm]
          end

          def allowed_event
            raise(ActionController::BadRequest) unless
              params[:event].to_sym.in?(send("#{payment.type.underscore}_allowed_events"))

            params[:event]
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Api
  module V1
    module Payments
      class StatusesController < PaymentsController
        def update
          raise ActionController::BadRequest unless payment.external?

          render_errors unless payment.public_send("#{allowed_event}!")
        end

        private

        def allowed_events
          case payment.type
          when 'Deposit'
            %i[check cancel]
          when 'Withdrawal'
            %i[confirm]
          end
        end

        def allowed_event
          raise(ActionController::BadRequest) unless params[:event].to_sym.in?(allowed_events)

          params[:event]
        end

        def render_errors
          errors = payment.errors.map do |error_object|
            ::JsonApi::Error.new(
              code: 422, title: error_object.attribute,
              detail: Array(error_object.message).join(', ')
            ).to_hash
          end

          render json: { errors: }, status: :unprocessable_entity
        end
      end
    end
  end
end

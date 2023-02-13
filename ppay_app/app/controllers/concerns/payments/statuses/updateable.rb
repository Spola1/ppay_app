# frozen_string_literal: true

module Payments
  module Statuses
    module Updateable
      extend ActiveSupport::Concern

      def update
        @payment.public_send("#{allowed_event}!", payment_params)

        render [role_namespace, 'payments', payment_type_namespace, 'show'].compact.join('/')
      end

      private

      def allowed_event
        raise(ActionController::BadRequest) unless params[:event].to_sym.in?(allowed_events)

        params[:event]
      end

      def payment_type_namespace
        model_class.underscore.pluralize unless role_namespace
      end
    end
  end
end

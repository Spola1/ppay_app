module Payments
  module Updateable
    extend ActiveSupport::Concern

    def update
      if @payment.public_send("#{ allowed_event }!", payment_params)
        render after_update_action
      else
        render after_update_action, status: :unprocessable_entity
      end
    end

    private

    def allowed_event
      params[:event].to_sym.in?(allowed_events) ?
        params[:event] :
        raise(ActionController::BadRequest)
    end
  end
end

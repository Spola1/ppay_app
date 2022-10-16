module Payments
  module Updateable
    extend ActiveSupport::Concern

    def update
      if @payment.public_send("#{ allowed_event }!", payment_params)
        after_update_success
      else
        after_update_error
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

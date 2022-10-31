module Payments
  module Updateable
    extend ActiveSupport::Concern

    def update
      @payment.public_send("#{ allowed_event }!", payment_params)

      render :show
    end

    private

    def allowed_event
      params[:event].to_sym.in?(allowed_events) ?
        params[:event] :
        raise(ActionController::BadRequest)
    end
  end
end

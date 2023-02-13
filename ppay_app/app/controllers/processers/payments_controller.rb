# frozen_string_literal: true

module Processers
  class PaymentsController < Staff::BaseController
    before_action :find_payment, only: %i[update show]

    def index
      @pagy, @payments = pagy(current_user.payments.includes(:merchant))
      @payments = @payments.decorate
    end

    def show; end

    def update
      @payment.update(payment_params)

      render :show
    end

    private

    def find_payment
      @payment = current_user.payments.find_by(uuid: params[:uuid]).becomes(model_class.constantize).decorate
    end

    def payment_params
      required_params.permit(:arbitration)
    end
  end
end

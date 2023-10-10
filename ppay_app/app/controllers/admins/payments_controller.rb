# frozen_string_literal: true

module Admins
  class PaymentsController < Staff::BaseController
    before_action :find_payment, only: %i[update show]

    def index
      @pagy, @payments = pagy(Payment.includes(:merchant).order(created_at: :desc))
      @payments = @payments.decorate

      @arbitration_payments_pagy, @arbitration_payments = pagy(Payment.arbitration.includes(:merchant),
                                                               page_param: :arbitration_page)
      @arbitration_payments = @arbitration_payments.decorate
    end

    def show; end

    def update
      if params[:fire_event]
        @payment.aasm.fire!(params[:event]) if params[:event].present?
      elsif params[:send_update_callback]
        @payment.send_update_callback
      else
        @payment.update(payment_params)
      end

      render :show
    end

    private

    def find_payment
      @payment = Payment.find_by(uuid: params[:uuid]).becomes(model_class.constantize).decorate
    end

    def payment_params
      required_params.permit(:arbitration, :cancellation_reason)
    end
  end
end

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
      @payment.update(payment_params)

      render :show
    end

    private

    def find_payment
      @payment = Payment.find_by(uuid: params[:uuid]).becomes(model_class.constantize).decorate
    end

    def payment_params
      required_params.permit(:payment_status, :arbitration, :cancellation_reason)
    end
  end
end

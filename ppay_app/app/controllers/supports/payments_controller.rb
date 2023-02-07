# frozen_string_literal: true

module Supports
  class PaymentsController < ApplicationController
    before_action :find_payment, only: %i[update show]

    def index
      @pagy, @payments = pagy(Payment.includes([:merchant]))
      @payments = @payments.decorate

      @pagy, @arbitration_payments = pagy(Payment.arbitration.includes([:merchant]))
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
      required_params.permit(:payment_status, :arbitration)
    end
  end
end

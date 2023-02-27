# frozen_string_literal: true

module Supports
  class PaymentsController < ApplicationController
    before_action :find_payment, only: %i[update show]

    def index
      @pagy, @payments = pagy(Payment.filter_by(filtering_params).includes(:merchant))
      @payments = @payments.decorate

      @arbitration_payments_pagy, @arbitration_payments = pagy(Payment.arbitration.filter_by(filtering_params).includes(:merchant),
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

    def filtering_params
      params.slice(:date_from, :date_to, :cancellation_reason, :payment_status, :payment_system, :national_currency,
                   :national_currency_amount_from, :national_currency_amount_to, :cryptocurrency_amount_from, 
                   :cryptocurrency_amount_to)
    end
  end
end

# frozen_string_literal: true

module Admins
  class PaymentsController < Staff::BaseController
    before_action :find_payment, only: %i[update show]

    def index
      @pagy, @payments = pagy(
        Payment.includes(:merchant, :arbitration_resolutions)
          .filter_by(filtering_params).order(created_at: :desc)
      )
      @payments = @payments.decorate

      @arbitration_payments_pagy, @arbitration_payments = pagy(
        Payment.arbitration.includes(:merchant, :arbitration_resolutions),
        page_param: :arbitration_page
      )
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

    def filtering_params
      params[:payment_filters]&.slice(:created_from, :created_to, :cancellation_reason, :payment_status,
                                      :payment_system, :national_currency, :national_currency_amount_from,
                                      :national_currency_amount_to, :cryptocurrency_amount_from,
                                      :cryptocurrency_amount_to, :uuid, :external_order_id, :card_number,
                                      :advertisement_id, :merchant)
    end
  end
end

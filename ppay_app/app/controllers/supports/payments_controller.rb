# frozen_string_literal: true

module Supports
  class PaymentsController < Staff::BaseController
    before_action :find_payment, only: %i[update show]

    def index
      respond_to do |format|
        format.html do
          set_all_payments
        end

        format.xlsx do
          render xlsx: 'payments',
                 locals: { payments: Payment.filter_by(filtering_params).includes(:merchant).decorate }
        end
      end
    end

    def show
      @payment_receipt = @payment.payment_receipts.new
    end

    def update
      @payment.update(payment_params)

      @payment.restore! if params[:restore]

      render :show
    end

    private

    def set_all_payments
      @pagy, @payments = pagy(Payment.filter_by(filtering_params).includes(:merchant))
      @payments = @payments.decorate

      @arbitration_payments_pagy, @arbitration_payments = pagy(filtered_payments, page_param: :arbitration_page)
      @arbitration_payments = @arbitration_payments.decorate
    end

    def find_payment
      @payment = Payment.find_by(uuid: params[:uuid]).becomes(model_class.constantize).decorate
    end

    def payment_params
      required_params.permit(:payment_status, :arbitration, :cancellation_reason, :arbitration_reason)
    end

    def filtering_params
      params[:payment_filters]&.slice(:created_from, :created_to, :cancellation_reason, :payment_status,
                                      :payment_system, :national_currency, :national_currency_amount_from,
                                      :national_currency_amount_to, :cryptocurrency_amount_from,
                                      :cryptocurrency_amount_to, :uuid, :external_order_id)
    end

    def filtered_payments
      Payment.arbitration.filter_by(filtering_params).includes(:merchant)
    end
  end
end

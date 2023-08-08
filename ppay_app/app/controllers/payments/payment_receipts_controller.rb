# frozen_string_literal: true

module Payments
  class PaymentReceiptsController < Staff::BaseController
    before_action :find_payment

    def create
      payment_receipt = @payment.payment_receipts.create(payment_receipt_params)

      if payment_receipt.save
        if @payment.arbitration?
          @payment.update(arbitration_reason: payment_receipt.receipt_reason)
        else
          @payment.update(arbitration: true, arbitration_reason: payment_receipt.receipt_reason)
        end

        render "#{role_namespace}/payments/show"
      end
    end

    private

    def find_payment
      @payment = Payment.find_by!(uuid: params[:payment_uuid]).decorate
    end

    def payment_receipt_params
      params.require(:payment_receipt).permit(:image, :comment, :receipt_reason).merge(source: :merchant_dashboard)
    end
  end
end

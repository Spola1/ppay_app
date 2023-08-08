# frozen_string_literal: true

module Payments
  class PaymentReceiptsController < Staff::BaseController
    before_action :find_payment

    def create
      payment_receipt = @payment.payment_receipts.create(payment_receipt_params)

      if payment_receipt.save
        @payment.update(
          arbitration: true,
          arbitration_reason: payment_receipt.receipt_reason
        )

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

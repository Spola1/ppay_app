# frozen_string_literal: true

module Payments
  class PaymentReceiptsController < Staff::BaseController
    before_action :find_payment

    def create
      payment_receipt = @payment.payment_receipts.create!(payment_receipt_params)

      @payment.update(arbitration: true) if payment_receipt.save
    end

    private

    def find_payment
      @payment = Payment.find_by!(uuid: params[:payment_uuid]).decorate
    end

    def payment_receipt_params
      params.require(:payment_receipt).permit(:image, :comment, :receipt_reason)
    end
  end
end

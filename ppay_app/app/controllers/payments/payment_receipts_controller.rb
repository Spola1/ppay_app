# frozen_string_literal: true

module Payments
  class PaymentReceiptsController < Staff::BaseController
    before_action :find_payment

    def create
      payment_receipt = @payment.payment_receipts.create(payment_receipt_params)
      payment_receipt.update(user: current_user)
      payment_receipt.save

      #debugger

      render "#{role_namespace}/payments/show" if payment_receipt.save
    end

    private

    def find_payment
      @payment = Payment.find_by!(uuid: params[:payment_uuid]).decorate
    end

    def payment_receipt_params
      case role_namespace
      when 'merchants'
        params.require(:payment_receipt).permit(:image, :comment, :receipt_reason, :start_arbitration).merge(source: :merchant_dashboard)
      when 'supports'
        params.require(:payment_receipt).permit(:image, :comment, :receipt_reason, :start_arbitration).merge(source: :support_dashboard)
      end
    end
  end
end

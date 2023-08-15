# frozen_string_literal: true

module Supports
  class PaymentReceiptsController < Staff::BaseController
    before_action :find_payment

    def create
      @payment_receipt = @payment.payment_receipts.new(payment_receipt_params.merge(user: current_user))

      if @payment_receipt.save && @payment_receipt.user.present?
        render "#{role_namespace}/payments/show"
      else
        render "#{role_namespace}/payments/show", status: :unprocessable_entity
      end
    end

    private

    def find_payment
      @payment = Payment.find_by!(uuid: params[:payment_uuid]).decorate
    end

    def payment_receipt_params
      params.require(:payment_receipt).permit(:image, :comment, :receipt_reason,
                                              :start_arbitration).merge(source: :support_dashboard)
    end
  end
end

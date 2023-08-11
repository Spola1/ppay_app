# frozen_string_literal: true

module Payments
  class PaymentReceiptsController < ApplicationController
    before_action :find_payment

    def create
      @payment_receipt = @payment.payment_receipts.new(payment_receipt_params.merge(user: current_user))

      if @payment_receipt.save && @payment_receipt.user.present?
        render "#{role_namespace}/payments/show"
      elsif !@payment_receipt.save && @payment_receipt.user.present?
        render "#{role_namespace}/payments/show", status: :unprocessable_entity
      else
        redirect_to "/payments/#{@payment.type.downcase}s/#{@payment.uuid}?signature=#{@payment.signature}"
      end
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
      when nil
        params.require(:payment_receipt).permit(:image, :comment, :receipt_reason, :start_arbitration).merge(source: :hpp_form)
      end
    end
  end
end

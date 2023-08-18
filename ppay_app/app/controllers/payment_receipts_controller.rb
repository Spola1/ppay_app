# frozen_string_literal: true

class PaymentReceiptsController < ApplicationController
  before_action :find_payment

  def create
    @payment_receipt = @payment.payment_receipts.new(payment_receipt_params.merge(user: current_user))

    if @payment_receipt.save
      redirect_to "/payments/#{@payment.type.downcase}s/#{@payment.uuid}?signature=#{@payment.signature}"
    end
  end

  private

  def find_payment
    @payment = Payment.find_by!(uuid: params[:payment_uuid]).decorate
  end

  def payment_receipt_params
    params.require(:payment_receipt).permit(:image, :comment, :receipt_reason,
                                            :start_arbitration).merge(source: :hpp_form)
  end
end

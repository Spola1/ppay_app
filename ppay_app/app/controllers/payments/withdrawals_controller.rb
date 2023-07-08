# frozen_string_literal: true

module Payments
  class WithdrawalsController < PaymentsController
    def index
      @pagy, @payments = pagy(Withdrawal.all)
    end

    def update
      @payment.assign_attributes(payment_params)
      @payment.save(context: :client)

      redirect_to "/payments/withdrawals/#{@payment.uuid}?signature=#{@payment.signature}"
    end

    private

    def required_params
      params.require(:withdrawal)
    end
  end
end

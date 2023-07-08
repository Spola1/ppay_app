# frozen_string_literal: true

module Payments
  class DepositsController < PaymentsController
    def index
      @pagy, @payments = pagy(Deposit.all)
    end

    def update
      @payment.assign_attributes(payment_params)
      @payment.save(context: :client)

      redirect_to "/payments/deposits/#{@payment.uuid}?signature=#{@payment.signature}"
    end

    private

    def required_params
      params.require(:deposit)
    end
  end
end

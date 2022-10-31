# frozen_string_literal: true

module Processers
  class PaymentsController < BaseController
    include ::Payments::Updateable

    before_action :find_payment, only: %i[update show]

    def index
      @deposits_confirming = Deposit.confirming.decorate
      @withdrawals_transferring = Withdrawal.transferring.decorate
      @payments = Payment.excluding(@deposits_confirming, @withdrawals_transferring).decorate
    end

    def show
      if @payment.rate_snapshot_id 
        @rate_snapshot = RateSnapshot.find(@payment.rate_snapshot_id)
        @exchange_portal = ExchangePortal.find(@rate_snapshot.exchange_portal_id)
      end
      @comments = @payment.comments
      @comment = Comment.new
    end

    private

    def find_payment
      @payment = Payment.find_by(uuid: params[:uuid]).becomes(model_class.constantize).decorate
    end

    def payment_params
      {}
    end
  end
end

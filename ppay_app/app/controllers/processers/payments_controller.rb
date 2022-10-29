# frozen_string_literal: true

module Processers
  class PaymentsController < BaseController
    include ::Payments::Updateable

    before_action :find_payment, only: %i[update show]

    def index
      @payments = Payment.all.order(created_at: :desc).decorate
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
      if params[:uuid] !~ /\D/
        # если строка содержит только цифры - значит это ID
        @payment = Payment.find(params[:id]).becomes(model_class.constantize).decorate
      else
        # если строка иная - скорее всего это UUID
        @payment = Payment.find_by(uuid: params[:uuid]).becomes(model_class.constantize).decorate
      end
    end

    def payment_params
      {}
    end
  end
end

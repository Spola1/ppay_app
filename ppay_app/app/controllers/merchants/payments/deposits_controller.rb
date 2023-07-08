# frozen_string_literal: true

module Merchants
  module Payments
    class DepositsController < PaymentsController
      def index
        @pagy, @payments = pagy(current_user.deposits)
        @payments = @payments.decorate
      end

      def show
        @payment = Payment.find_by(uuid: params[:uuid]).becomes(model_class.constantize).decorate
        render 'supports/payments/show'
      end

      def new
        @payment = Payment.new
      end

      def create
        @payment = Payment.new(payment_params)
        @payment.uuid = SecureRandom.uuid
        @payment.save
        if @payment.errors.empty?
          redirect_to "/payments/deposits/#{@payment.uuid}/display_link"
        else
          flash[:payment] = @payment.errors.full_messages
          render 'new'
        end
      end

      def display_link
        @payment = Payment.find_by(uuid: params[:uuid]).becomes(model_class.constantize).decorate
        render 'merchants/payments/display_link'
      end

      private

      def payment_params
        params.require(:deposit).permit(:national_currency_amount, :national_currency, :direction, :redirect_url,
                                        :callback_url, :external_order_id, :locale).merge(merchant_id: current_user.id)
      end
    end
  end
end

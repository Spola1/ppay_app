# frozen_string_literal: true

module Merchants
  module Payments
    class DepositsController < PaymentsController
      before_action :find_payment, only: %i[display_link update show]

      def index
        @pagy, @payments = pagy(current_user.deposits)
        @payments = @payments.decorate
      end

      def show; end

      def update
        @payment.assign_attributes(payment_params)

        render :show if @payment.save(context: :merchant)
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
        render 'merchants/payments/display_link'
      end

      private

      def find_payment
        @payment = Payment.find_by(uuid: params[:uuid]).becomes(model_class.constantize).decorate
      end

      def payment_params
        params.require(:deposit).permit(:national_currency_amount, :national_currency, :direction, :redirect_url,
                                        :callback_url, :external_order_id, :locale,
                                        :arbitration, :arbitration_reason, :image, :cancellation_reason
                                       ).merge(merchant_id: current_user.id)
      end
    end
  end
end

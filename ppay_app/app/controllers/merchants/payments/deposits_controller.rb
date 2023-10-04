# frozen_string_literal: true

module Merchants
  module Payments
    class DepositsController < PaymentsController
      before_action :find_payment, only: %i[display_link update show]

      def index
        @pagy, @payments = pagy(current_user.deposits)
        @payments = @payments.decorate
      end

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

          uid = Rails.application.credentials.bnn_pay[:uid]
          private_key = Rails.application.credentials.bnn_pay[:private_key]

          params = {
            orderId: @payment.external_order_id,
            amount: @payment.national_currency_amount,
            callbackUrl: 'https://webhook.site/04111f50-f182-4871-ac16-e5d388b464f2',
            returnUrl: 'https://webhook.site/04111f50-f182-4871-ac16-e5d388b464f2'
          }

          #debugger

          sorted_params = params.sort.map { |k, v| "#{k}=#{v}" }.join('&')
          signature_body = "#{uid}:#{private_key}:#{sorted_params}"

          url = "#{ENV.fetch('BNN_PROTOCOL')}://#{ENV.fetch('BNN_ADDRESS')}/#{ENV.fetch('BNN_PATH')}?#{sorted_params}"

          RestClient.post(url, {}, { Authorization: "UID #{uid}", SIGNATURE: Digest::MD5.hexdigest(signature_body) })


          redirect_to "/payments/deposits/#{@payment.uuid}/display_link"
        else
          flash[:payment] = @payment.errors.full_messages
          render 'new'
        end
      end

      def handle_callback
      end

      def handle_return
      end

      def display_link
        render 'merchants/payments/display_link'
      end

      private

      def payment_params
        params.require(:deposit).permit(:national_currency_amount, :national_currency, :direction, :redirect_url,
                                        :callback_url, :external_order_id, :locale,
                                        :arbitration, :arbitration_reason, :image, :cancellation_reason).merge(merchant_id: current_user.id)
      end
    end
  end
end

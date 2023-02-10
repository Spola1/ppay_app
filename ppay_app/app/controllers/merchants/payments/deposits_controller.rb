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
    end
  end
end
